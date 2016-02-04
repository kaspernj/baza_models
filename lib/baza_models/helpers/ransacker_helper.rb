module BazaModels::Helpers::RansackerHelper
  def bm_sort_link(ransacker, attribute)
    require "html_gen"

    label = ransacker.klass.human_attribute_name(:attribute)

    new_params = params.clone
    new_params[:s] = "#{attribute} asc"

    href = url_for(new_params)

    element = HtmlGen::Element.new(:a, str: label, attr: {href: href})
    element.html
  end
end
