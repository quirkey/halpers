module QuirkeyHelper
  
  def rss_feed(xml,params = {},&block)
    xml.instruct!
    xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
      xml.channel do
        xml.title       params[:title]
        xml.link        params[:link]
        xml.pubDate     CGI.rfc1123_date(params[:pub_time] || Time.now)
        xml.description params[:description]

        yield

      end
    end
  end

  def rss_item(xml,params = {})
    xml.item do
      xml.title       params[:title]
      xml.link        params[:link]
      xml.description do |d|
        xml.cdata! params[:description]
      end
      xml.pubDate     CGI.rfc1123_date(params[:pub_time] || Time.now)
      xml.guid        params[:link]
      xml.author      params[:author]
    end
  end
  
  def truncate_words(text, length = 30, truncate_string = "..." )
    return if text.nil?
    words = text.split
    words.length > length ? words[0...length].join(" ") + truncate_string : text
  end
  
  def sub_items_if_content(item,sub_items)
    sub_items.each do |sub_item|
      if item.send(sub_item) && item.send(sub_item).length > 0
        yield sub_item, item.send(sub_item)
      end
    end
  end
  
  def selected_if_current(url_options, css = 'class="selected"')
    css if like_current_page?(url_options)
  end
  
  def selected_if(comparison,css = 'class="selected"')
    css if comparison
  end
  
  def like_current_page?(options)
    case options
    when Hash
      url_string = Regexp.new(CGI.escapeHTML(url_for(options)))
    when String
      url_string = Regexp.new(options)
    when Regexp
      url_string = options
    end
    request = @controller.request
    # if url_string =~ /^\w+:\/\//
    #   "#{request.protocol}#{request.host_with_port}#{request.request_uri}" =~ url_string
    # else
      request.request_uri =~ url_string
    # end
  end
  
  def yes?(bool)
    bool ? "Yes" : "No"
  end
  
  def simple_select_tag(name, options, current = nil, id = nil, html_params = {})
    ht = "<select name=\"#{name}\" id=\"" + (id || name.underscore) + "\" " +
         html_params.to_a.inject(""){|str, html_param_pair| str + " #{html_param_pair[0]}=\"#{html_param_pair[1]}\""} + ">"
    ht << simple_select_options(options, current)
    ht << "</select>"; ht
  end

  def simple_select_options(options, current = nil)
    returning("") do |ht|
      options.each do |option|
        if option.is_a?(ActiveRecord::Base) && (current.is_a?(ActiveRecord::Base) || current.nil?)
          ht << "<option value=\"#{option.id}\""
          ht << " selected=\"selected\"" if (current && option.id == current.id)
          ht <<">#{option}</option>"
        elsif option.is_a?(Array)
          ht << "<option value=\"#{option[1]}\""
          ht << " selected=\"selected\"" if option[1].to_s == current.to_s
          ht <<">#{option[0]}</option>"
        else
          ht << "<option value=\"#{option}\""
          ht << " selected=\"selected\"" if option.to_s == current.to_s
          ht <<">#{option}</option>"
        end
      end
    end
  end

  
  def simple_select(obj,method,options,current = nil, id = nil)
    simple_select_tag("#{obj}[#{method}]",options,(current ? current.send(method) : nil),id)
  end
  
  def li(content, *args)
    content_tag :li, content, args
  end
   
  def simple_admin_menu(*controllers)
    html = %{<div id="menu">
  		<ul>}
  		simple_menu(*controllers) do |name,controller|
			  li(link_to(name, :controller => controller))
			end
  	html <<	%{</ul>
  		<div class="clear"></div>
  	</div>}
  end

  def simple_menu(*controllers, &block)
    returning("") do |html|
      controllers.each do |controller_pair|
        if controller_pair.is_a? Array
          name, controller = controller_pair[0], controller_pair[1]
        else
          name, controller = controller_pair.humanize.downcase, controller_pair
        end
        html << yield(name,controller)
      end
    end
  end

  def hide_unless(this_is_true)
    this_is_true ? '' : ' style="display:none;"'
  end
  
end
