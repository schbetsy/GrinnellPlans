require 'plan_generation/link_planloves'

class Plan < ActiveRecord::Base
  include PlanGeneration::LinkPlanloves

  belongs_to :account, foreign_key: :user_id
  before_save :clean_text
  after_update :set_modified_time
  alias_attribute :generated_html, :plan
  # validates_presence_of :account
  validates_length_of :plan, maximum: 16_777_215, message: 'Your plan is too long'
  validates_length_of :edit_text, maximum: 16_777_215, message: 'Your plan is too long'

  ALLOWED_HTML = {
      elements: %w[ a b hr i p span pre tt code br ],
      attributes: {
        'a' => ['href'],
        'span' => ['class'],
      },
      protocols: {
        'a' => { 'href' => %w[http https mailto] }
      },
    }

  # TODO: Consider migrating user_id to userid, like everythig else
  def userid
    user_id
  end

  def generated_html
    read_attribute(:plan).html_safe
  end

  def clean_text
    renderer = Redcarpet::Render::HTML.new hard_wrap: true, no_images: true
    markdown = Redcarpet::Markdown.new(
      renderer,
      no_intra_emphasis: true,
      strikethrough: true,
      lax_html_blocks: true,
      space_after_headers: true
    )
    plan = markdown.render edit_text

    # Convert some legacy elements
    { u: :underline, strike: :strike, s: :strike }.each do |in_class, out_class|
      pattern = Regexp.new "<#{in_class}>(.*?)<\/#{in_class}>"
      replacement = "<span class=\"#{out_class}\">\\1</span>"
      plan.gsub! pattern, replacement
    end

    # Now sanitize any bad elements
    plan_html = Sanitize.clean plan, ALLOWED_HTML

    self.generated_html = link_loves plan_html

  end

  private

  def set_modified_time
    account.changed = Time.now
    account.save!
  end
end
