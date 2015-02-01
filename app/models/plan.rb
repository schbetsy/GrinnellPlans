require 'plan_generation/link_planloves'
require 'plan_generation/generate_plan'

class Plan < ActiveRecord::Base
  include PlanGeneration::LinkPlanloves
  include PlanGeneration::GeneratePlan

  belongs_to :account, foreign_key: :user_id
  before_save :clean_text
  after_update :set_modified_time
  alias_attribute :generated_html, :plan
  # validates_presence_of :account
  validates_length_of :plan, maximum: 16_777_215, message: 'Your plan is too long'
  validates_length_of :edit_text, maximum: 16_777_215, message: 'Your plan is too long'

  # TODO: Consider migrating user_id to userid, like everythig else
  def userid
    user_id
  end

  def generated_html
    read_attribute(:plan).html_safe
  end

  def clean_text
    # Make newlines and other special characters html-friendly, wrap body in <p> tags
    formatted_plan = process_markdown(edit_text)

    # Convert legacy elements
    updated_plan = convert_legacy_tags(formatted_plan)

    # Sanitize any bad elements
    valid_plan = remove_disallowed_tags(updated_plan)

    # Make planloves and other links into <a> tags
    plan_with_love_links = link_loves(valid_plan)
    require 'pry'; binding.pry

    # self.update_attributes(plan: plan_with_love_links)
    self.plan = plan_with_love_links
    self.save
  end

  private

  def set_modified_time
    account.changed = Time.now
    account.save!
  end
end
