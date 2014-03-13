@url = url_for(:only_path => false).gsub("/posts", "")

xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title("Sam Saffron")
    xml.link(@url + "/posts.rss")
    xml.description("Sam Saffron's blog")
    xml.language('en-us')

    for topic in @topics
      xml.item do
        xml.title(topic.title)
        xml.description(topic.cooked)
        xml.pubDate(topic.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link(@url + permalink(topic))
      end
    end
  end
end

