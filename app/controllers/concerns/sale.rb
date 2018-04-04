require 'openssl'
require 'net/http'

module Sale
  def new_request(sale)
    request = Net::HTTP::Post.new("/ipgapi/services")

    request.basic_auth ENV["USERNAME"], ENV["PASSWORD"]
    request.content_type = "text/xml"
    request.body = new_sale(sale)

    http.request(request)
  end

  def new_sale(sale)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml['env'].Envelope(
        "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/",
        "xmlns:v1" => "http://ipg-online.com/ipgapi/schemas/ipgapi"
      ) {
        xml['env'].Body {
          xml['ipgapi'].IPGApiOrderRequest(
            'xmlns:v1' => 'http://ipg-online.com/ipgapi/schemas/v1',
            'xmlns:ipgapi' => 'http://ipg-online.com/ipgapi/schemas/ipgapi'
          ) {
            xml['v1'].Transaction {
              xml['v1'].CreditCardTxType {
                xml['v1'].Type "sale"
              }
              xml['v1'].CreditCardData {
                xml['v1'].CardNumber sale["card_number"]
                xml['v1'].ExpMonth sale["expiry_month"]
                xml['v1'].ExpYear sale["expiry_year"]
                xml['v1'].CardCodeValue sale["card_code"]
              }
              xml['v1'].Payment {
                xml['v1'].ChargeTotal sale["charge_total"]
                xml['v1'].Currency "978"
              }
            }
          }
        }
      }
    end
    builder.to_xml
  end

private

  def http(http = nil)
    http ? http : Net::HTTP.start(uri.host, uri.port, default_options)
  end

  def default_options
    {
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_PEER,
      keep_alive_timeout: 30,
      cert: cert,
      key: key
    }
  end

  def uri
    URI.parse("https://test.ipg-online.com")
  end

  def cert
    OpenSSL::X509::Certificate.new(File.read('./lib/certs/authipay.pem'))
  end

  def key
    OpenSSL::PKey::RSA.new(File.read('./lib/certs/authipay.key'), ENV["CLIENT_KEY"])
  end
end
