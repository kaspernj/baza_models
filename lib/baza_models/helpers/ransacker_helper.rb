module BazaModels::Helpers::RansackerHelper
  def bm_paginate_content(collection)
    require "html_gen"

    new_params = params.dup
    current_page = collection.page
    total_pages = collection.total_pages

    container = HtmlGen::Element.new(:div)

    if current_page > 1
      new_params[:page] = current_page - 1
      container.add_ele(:a, str: "Previous", attr: {href: url_for(new_params)})
    else
      container.add_ele(:span, str: "Previous")
    end

    1.upto(collection.total_pages) do |page_i|
      new_params[:page] = page_i

      link = container.add_ele(:a, attr: {href: url_for(new_params)})

      if page_i == current_page
        link.add_ele(:b, str: page_i.to_s)
      else
        link.add_str(page_i.to_s)
      end
    end

    if current_page < total_pages
      new_params[:page] = current_page + 1
      container.add_ele(:a, str: "Next", attr: {href: url_for(new_params)})
    else
      container.add_ele(:span, str: "Next")
    end

    container.html
  end

  def bm_sort_link(ransacker, attribute, label = nil)
    require "html_gen"

    label = ransacker.klass.human_attribute_name(attribute) if label.to_s.strip.empty?

    new_params = params.clone
    new_params[:q] ||= {}

    sort_asc = "#{attribute} asc"

    if new_params[:q][:s] == sort_asc
      new_params[:q][:s] = "#{attribute} desc"
    else
      new_params[:q][:s] = sort_asc
    end

    href = url_for(new_params)

    element = HtmlGen::Element.new(:a, str: label, attr: {href: href})
    element.html
  end
end
