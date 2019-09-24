class Scraper 
    attr_accessor :items_attributes, :page_url, :file_path
    
    def initialize(resource_url, file_path)
        @page_url = resource_url
        @items_attributes = []
    end

    def get_category_items
        index = 1
        loop do
            category_page = counter_page_xml(index)
            items = category_page.xpath('//a[@class="product_img_link product-list-category-img"]/@href')
            puts "parsing page #{index}"
            break unless items.any?
            items.each do |element|
                item_page_url = convet_page_to_xml(element)
                item_image, item_main_name, item_weight, item_price = items_param(item_page_url).values
                if item_weight.count == 0
                    item_price = item_page_url.xpath('//span[@id="our_price_display"]').text.strip
                    items_attributes << [item_main_name, item_price.to_f, item_image.to_s]
                else
                    item_weight.each_with_index do |item_weight_element, item_index|
                    items_attributes << [
                        item_main_name + ' - ' + item_weight_element.text.strip,
                        item_price[item_index].text.strip.to_f,
                        item_image.to_s
                    ]
                    end
                end
            end 
            puts ' '
            index += 1
        end         
    end

    def export_into_csv(filename)
        puts 'exporting into csv file...'
        CSV.open("#{filename}", "a+") do |csv|
            csv << %w[title price image]
            items_attributes.each do |item_attributes|
                csv << item_attributes
            end
        end
        puts "done, filename: #{filename}"
    end

    def items_param(item_page_url)
        {
            item_image: item_page_url.xpath('//img[@id="bigpic"]/@src'),
            item_main_name: item_page_url.xpath('//h1[@class="product_main_name"]').text.strip,
            item_weight: item_page_url.xpath('//span[@class="radio_label"]'),
            item_price: item_page_url.xpath('//span[@class="price_comb"]')
        }
    end

    def counter_page_xml(page)
        url = page_url
        url += "/?p=#{page}" unless page == 1
        category_page_xml = convet_page_to_xml(url)
      end

    def convet_page_to_xml(url)
        puts "Getting page #{url}"
        page = Curl.get(url) do |http|
            http.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
        end
        convet_page_to_xml = Nokogiri::HTML(page.body_str)
    end

end