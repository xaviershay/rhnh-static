module Jekyll
  class LinkPostTag < Liquid::Tag
    def render(context)
      post = context['post']
      date = post['date']
      slug = post['slug']

      "/%s/%s" % [date.strftime("%Y/%m/%d"), slug]
    end
  end
end

Liquid::Template.register_tag('post_link', Jekyll::LinkPostTag)
