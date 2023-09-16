require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'openai'
require './message_handler'

def get_access_token
  # アクセストークンの取得
  resp = Net::HTTP.post_form(
    URI("https://login.microsoftonline.com/botframework.com/oauth2/v2.0/token"),
    {
      'grant_type' => 'client_credentials',
      'client_id' => ENV['MICROSOFT_CLIENT_ID'],
      'client_secret' => ENV['MICROSOFT_CLIENT_SECRET'],
      'scope' => 'https://api.botframework.com/.default',
    }
  )
  resp_body = JSON.parse(resp.body)
  resp_body['access_token']
end

def chat_completion(prompt)
  # OpenAI API処理
  openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  openai_resp = openai_client.chat(
    parameters: {
      model: "gpt-3.5-turbo-16k-0613",
      messages: [
        {
          "role": "system",
          "content": "あなたはアシスタントです。"
        },
        {
          "role": "user",
          "content": "#{prompt}"
        }
      ]
    }
  )
end

def reply_message(msg_handler)
  # メッセージ返信処理
  resp = Net::HTTP.post(
    URI("#{msg_handler.bot_uri}"),
    msg_handler.reply_json,
    {
      'Authorization' => "Bearer #{$access_token}",
      'Content-Type' => 'application/json'
    }
  )
  resp_body = JSON.parse(resp.body)
end

post '/messages' do
  logger = Logger.new(STDOUT);

  json_body = JSON.parse(request.body.read)
  # コンソール出力
  logger.info("bot-params:#{json_body}")

  # 出力データは全てJSON形式
  content_type :json

  case json_body['type']
  when 'conversationUpdate' then
    # アクセストークンの取得
    if $access_token == nil
      $access_token = get_access_token
    end

    status 200
    { status: 200 }.to_json
  when 'message' then
    # アクセストークンの取得
    if $access_token == nil
      $access_token = get_access_token
    end

    # OpenAI API処理
    openai_resp = chat_completion(json_body['text'])
    # コンソール出力
    logger.info("openai-resp:#{openai_resp}")

    msg_handler = MessageHandler.new(json_body)
    msg_handler.reply_text = openai_resp['choices'][0]['message']['content'] + '<a href="https://www.google.co.jp/">Google</a>'

    # メッセージ返信処理
    # resp_body = msg_handler.reply(botService)
    resp_body = reply_message(msg_handler)
    # コンソール出力
    logger.info("bot-resp:#{resp_body}")

    status 200
    { status: 200 }.to_json
  else
    status 500
    { status: 500 }.to_json
  end
end