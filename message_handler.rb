# パラメーターサンプル type:conversationUpdate
# ただし、本クラスで扱うメッセージはmessageのみとする。
# {
# 	"type": "conversationUpdate",
# 	"id": "5Ou42SpmgXE",
# 	"timestamp": "2023-08-26T07:32:53.729906Z",
# 	"serviceUrl": "https://webchat.botframework.com/",
# 	"channelId": "webchat",
# 	"from": {
# 		"id": "e63f1a2f-d5ae-49d3-bdcf-95042ab62f85"
# 	},
# 	"conversation": {
# 		"id": "FJlNDNM3esRK6PZCvnWJds-as"
# 	},
# 	"recipient": {
# 		"id": "STRAIBot@2SZuGPcPars",
# 		"name": "STRAIBot"
# 	},
# 	"membersAdded": [
# 		{
# 			"id": "STRAIBot@2SZuGPcPars",
# 			"name": "STRAIBot"
# 		},
# 		{
# 			"id": "e63f1a2f-d5ae-49d3-bdcf-95042ab62f85"
# 		}
# 	]
# }
# パラメーターサンプル(Teams) type:message
# {
#   "type": "message",
#   "id": "8WUCYacspeB8TPUWWCsi3s-as|0000004",
#   "timestamp": "2023-08-24T08:55:38.3125253Z",
#   "localTimestamp": "2023-08-24T17:55:37.653+09:00",
#   "localTimezone": "Asia/Tokyo",
#   "serviceUrl": "https://webchat.botframework.com/",
#   "channelId": "webchat",
#   "from": {
#     "id": "e63f1a2f-d5ae-49d3-bdcf-95042ab62f85",
#     "name": ""
#   },
#   "conversation": {
#     "id": "8WUCYacspeB8TPUWWCsi3s-as"
#   },
#   "recipient": {
#     "id": "STRAIBot@2SZuGPcPars",
#     "name": "STRAIBot"
#   },
#   "textFormat": "plain",
#   "locale": "ja",
#   "text": "aaa",
#   "attachments": [],
#   "channelData": {
#     "clientActivityID": "1692867337652wwkpzfbqkw"
#   }
# パラメーターサンプル(Teams) type:message
# {
# 	"text": "こんにちは",
# 	"textFormat": "plain",
# 	"attachments": [
# 		{
# 			"contentType": "text/html",
# 			"content": "<p>こんにちは</p>"
# 		}
# 	],
# 	"type": "message",
# 	"timestamp": "2023-08-26T13:49:58.2759207Z",
# 	"localTimestamp": "2023-08-26T22:49:58.2759207+09:00",
# 	"id": "1693057798124",
# 	"channelId": "msteams",
# 	"serviceUrl": "https://smba.trafficmanager.net/jp/",
# 	"from": {
# 		"id": "29:1f2B7ivVFMPrf3NFjgYlLdLi8u3FYuZ664Jjkb0Gv8_lgoV4Qszk1iuaY6KusqLfIxr1okRgIP-Zsv7BoQO9oeA",
# 		"name": "高橋 一道",
# 		"aadObjectId": "e63f1a2f-d5ae-49d3-bdcf-95042ab62f85"
# 	},
# 	"conversation": {
# 		"conversationType": "personal",
# 		"tenantId": "fa67e216-cc12-4c97-8ca5-93a1c6ff4160",
# 		"id": "a:1e073frDwGadairyMCUbF-e0oNbhclgoU6w3rimirTH9ae189uF-d6kSQoNHDBWIsiI0JSEF9j0S3V_jHNgZjKrHoP4tldpF1hYDzkZCqXjlpj4H6WfFQ-9XF5ItoDbBO"
# 	},
# 	"recipient": {
# 		"id": "28:d546d171-a494-451e-b587-d5874e36968e",
# 		"name": "STRAIBot"
# 	},
# 	"entities": [
# 		{
# 			"locale": "ja-JP",
# 			"country": "JP",
# 			"platform": "Web",
# 			"timezone": "Asia/Tokyo",
# 			"type": "clientInfo"
# 		}
# 	],
# 	"channelData": {
# 		"tenant": {
# 			"id": "fa67e216-cc12-4c97-8ca5-93a1c6ff4160"
# 		}
# 	},
# 	"locale": "ja-JP",
# 	"localTimezone": "Asia/Tokyo"
# }
# パラメーターサンプル(LINE) type:message
# {
#   "type": "message",
#   "id": "Izxm7T3iNfC",
#   "timestamp": "2023-08-26T09:47:05.3002349Z",
#   "serviceUrl": "https://line.botframework.com/",
#   "channelId": "line",
#   "from": {
#     "id": "U13493544687abe5b28faece3c4b28576",
#     "name": "K"
#   },
#   "conversation": {
#     "isGroup": false,
#     "id": "U13493544687abe5b28faece3c4b28576|HFEzuHkXetA"
#   },
#   "recipient": {
#     "id": "HFEzuHkXetA",
#     "name": "STRAIBot"
#   },
#   "text": "こんにちは",
#   "channelData": {
#     "message": {
#       "text": "こんにちは",
#       "id": "470117591600595109",
#       "type": "text"
#     },
#     "replyToken": "b6e83d47f2754688874a731f376e4d95",
#     "type": "message",
#     "source": {
#       "type": "user",
#       "userId": "U13493544687abe5b28faece3c4b28576"
#     },
#     "timestamp": 1693043224509
#   }
# }

class MessageHandler
  attr_accessor :reply_text

  def initialize(params)
    if params['type'] != 'message'
      return
    end

    @channelId = params['channelId']
    @serviceUrl = params['serviceUrl']
    @from = {
      'id' => params['from']['id'],
      'name' => params['from']['name']
    }
    @conversation = {
      'id' => params['conversation']['id'],
      'name' => ''
    }
    @recipient = {
      'id' => params['recipient']['id'],
      'name' => params['recipient']['name']
    }
    case @channelId
    when 'webchat' then
      @channelData = {
        'id' => params['channelData']['clientActivityID']
      }
    when 'msteams' then
      @channelData = {
        'id' => params['channelData']['tenant']['id']
      }
    when 'line' then
      @channelData = {
        'id' => params['channelData']['message']['id']
      }
    end
    @text = params['text']
    @reply_text = ''
  end

  def bot_uri
    case @channelId
    when 'webchat' then
      "#{@serviceUrl}v3/conversations/#{@conversation['id']}/activities/#{@channelData['id']}"
    when 'msteams' then
      # "#{@serviceUrl}v3/conversations/#{@conversation['id']}/activities/#{@channelData['id']}"
      encode_str = CGI.escape(@conversation['id'])
      # "#{@serviceUrl}v3/conversations/#{encode_str}/activities/#{@channelData['id']}"
      "#{@serviceUrl}v3/conversations/#{encode_str}/activities"
    when 'line' then
      # "#{@serviceUrl}v3/conversations/#{@conversation['id']}/activities"
      # encode_str = Base64.encode64(@conversation['id'])
      encode_str = CGI.escape(@conversation['id'])
      "#{@serviceUrl}v3/conversations/#{encode_str}/activities"
    end
  end

  def get_message_header
    {
      "type": "message",
      "from": {
        "id": @recipient['id'],
        "name": @recipient['name']
      },
      "conversation": {
        "id": @conversation['id'],
        "name": @conversation['name']
      },
      "recipient": {
        "id": @from['id'],
        "name": @from['name']
      }
    }
  end

  def to_json
    message_header = get_message_header
    message_header['text'] = @text
    message_header.to_json
  end

  def reply_json
    message_header = get_message_header
    message_header['text'] = @reply_text
    message_header.to_json
  end
end
