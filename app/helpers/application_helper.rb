module ApplicationHelper
  def title
    base_title = "Pet Diary"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  def gravatar_for(user, options = {:size => 50})
    gravatar_image_tag(user.email.downcase,
                       :alt => user.name,
                       :class => 'gravatar',
                       :gravatar => options)
  end

  def markdown(str)
    return nil if str.nil?
    BlueCloth.new(sanitize(str,
                           :tags => ['table', 'tr', 'td', 'div', 'span', 'section',
                                     'br'],
                           :attributes => ['id', 'class', 'style'])).to_html
  end

  def add_debug(obj)
    if Rails.env.development? || Rails.env.test?
      @debug_objs ||= []
      @debug_objs.push(obj)
    end
  end
end
