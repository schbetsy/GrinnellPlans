class PagesController < ApplicationController
  layout 'minimal'

  def show
    page_name = params[:id]
    expanded_page = "#{Rails.root}/app/views/pages/#{page_name}.html.haml"
    exists = File.exist?(File.expand_path(expanded_page))
    if exists
      render action: page_name
    else
      render text: "#{page_name} doesn't exist."
    end
  end
end
