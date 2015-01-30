module PlanGeneration
  module LinkPlanloves

    def link_loves(plan_html)
      # TODO: make actual rails links, probably in helper
      logger.debug('self.plan________' + plan_html)
      checked = {}
      loves = plan_html.scan(/\[(.*?)\]/)# get an array of everything in brackets
      loves.each do |love|
        item = love.first
        unless checked[item]
          checked[item] = true

          if item.match(/^\d+$/) && SubBoard.find(:first, conditions: { messageid: item })
            # TODO:  Regexp.escape(item, "/")
            plan_html.gsub!(/\[#{Regexp.escape(item)}\]/, "[<a href=\"board_messages.php?messagenum=$item#{item}\" class=\"boardlink\">#{item}</a>]")
            next
          end

          if item =~ /:/
            if item =~ /\|/
              # external link with name
              love_replace = item.match(/(.+?)\|(.+)/i)
              plan_html.gsub!(/\[#{Regexp.escape(item)}\]/, "<a href=\"#{love_replace[1]}\" class=\"onplan\">#{love_replace[2]}</a>")
            else
              # external link without name
              plan_html.gsub!(/\[#{Regexp.escape(item)}\]/, "<a href=\"#{item}\" class=\"onplan\">#{item}</a>")
            end
            next
          end

          account = Account.where(username: item.downcase).first
          unless account.blank?
            # change all occurences of person on plan
            plan_html.gsub!(/\[#{item}\]/, "[<a href=\"#{Rails.application.routes.url_helpers.read_plan_path account.username}\" class=\"planlove\">#{item}</a>]")
          end
        end

      end

      logger.debug('self.plan________' + plan_html)
      plan_html
    end
  end
end
