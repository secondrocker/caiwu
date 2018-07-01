module ApplicationHelper
  def button_to_function(name, function=nil, html_options={})
    message = "button_to_function is deprecated and will be removed from Rails 4.1. Use Unobtrusive JavaScript instead."
    ActiveSupport::Deprecation.warn message

    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"

    tag(:input, html_options.merge(:type => 'button', :value => name, :onclick => onclick))
  end

  # Returns a link whose +onclick+ handler triggers the passed JavaScript.
  #
  # The helper receives a name, JavaScript code, and an optional hash of HTML options. The
  # name is used as the link text and the JavaScript code goes into the +onclick+ attribute.
  # If +html_options+ has an <tt>:onclick</tt>, that one is put before +function+. Once all
  # the JavaScript is set, the helper appends "; return false;".
  #
  # The +href+ attribute of the tag is set to "#" unless +html_options+ has one.
  #
  #   link_to_function "Greeting", "alert('Hello world!')", :class => "nav_link"
  #   # => <a class="nav_link" href="#" onclick="alert('Hello world!'); return false;">Greeting</a>
  #
  def link_to_function(name, function, html_options={})
    message = "link_to_function is deprecated and will be removed from Rails 4.1. Use Unobtrusive JavaScript instead."
    ActiveSupport::Deprecation.warn message

    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end

  def link_to_new_ss(name, f)
    new_object = f.object.subscriptions_sales.build
    id = new_object.object_id
    fields =(render partial:'/subscriptions/subscription_sale',locals:{ss:new_object,f:f})
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_new_os(name,f)
    new_object = f.object.orders_sales.build
    id = new_object.object_id
    fields =(render partial:'/orders/order_sale',locals:{os:new_object,f:f})
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def link_to_new_payment(name,f)
    new_object = f.object.payments.build
    id = new_object.object_id
    fields =(render partial:'/orders/payment',locals:{payment:new_object,f:f})
    link_to(name, '#', class: "add_to_order", data: {id: id, fields: fields.gsub("\n", "")})
  end
end
