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
    # msg_handler.reply_text = openai_resp['choices'][0]['message']['content']
    msg_handler.reply_text = '<h1>「株式移転比率が時価ではなかった時の課税関係を条文を引用して解説してください」について、検索結果および生成された文章を表示します。</h1>
<h2>「法令DB」の検索結果</h2>
1. <a href="https://elaws.e-gov.go.jp/document?lawid=329AC0000000194_20170401_000000000000000&keyword=%E8%AA%B2%E7%A8%8E">遺産、相続及び贈与に対する租税に関する二重課税の回避及び脱税の防止のための日本国とアメリカ合衆国との間の条約の実施に伴う相続税法の特例等に関する法律（昭和二十九年法律第百九十四号）</a><br>
公布日：昭和二十九年六月二十三日|（平成２９年４月１日（基準日）現在のデータ）<br>
2. <a href="https://elaws.e-gov.go.jp/document?lawid=337AC0000000144_20230401_505AC0000000003&keyword=%E8%AA%B2%E7%A8%8E">外国居住者等の所得に対する相互主義による所得税等の非課税等に関する法律（昭和三十七年法律第百四十四号）</a><br>
公布日：昭和三十七年五月二十五日|施行日：令和五年四月一日|（令和五年法律第三号による改正）<br>
3. <a href="https://elaws.e-gov.go.jp/document?lawid=348AC0000000102_20150801_000000000000000&keyword=%E8%AA%B2%E7%A8%8E">特定市街化区域農地の固定資産税の課税の適正化に伴う宅地化促進臨時措置法（昭和四十八年法律第百二号）</a><br>
公布日：昭和四十八年九月二十九日|（平成２７年８月１日（基準日）現在のデータ）<br>
<h2>「判例DB」の検索結果</h2>
1. <a href="https://www.courts.go.jp/app/hanrei_jp/detail7?id=92348">知的財産裁判例</a><br>
令和2(ワ)13317 　特許権侵害損害賠償等請求事件 　特許権 　民事訴訟、令和5年7月13日 　東京地方裁判所<br>
2. <a href="https://www.courts.go.jp/app/hanrei_jp/detail4?id=92323">下級裁裁判例</a><br>
令和4(行コ)164 　固定資産税及び都市計画税賦課決定処分取消請求控訴事件<br>
3. <a href="https://www.courts.go.jp/app/hanrei_jp/detail5?id=92323">行政事件裁判例</a><br>
令和5年6月29日 　大阪高等裁判所 　破棄自判 　大阪地方裁判所<br>
<h2>「通達DB」の検索結果</h2>
1. <a href="https://www.google.com/url?client=internal-element-cse&cx=002894216937212238947:kbug-tlua7u&q=https://www.nta.go.jp/law/tsutatsu/kihon/shotoku/kaisei/230707/pdf/02.pdf&sa=U&ved=2ahUKEwiOjNGAwq-BAxU_pVYBHbcHBcUQFnoECAcQAg&usg=AOvVaw0BXst6M2NwkkGf_TGfFNZO">令和 5 年5月 ストックオプションに対する課税（Q＆A）</a><br>
2023/07/07 ... により、課税が繰り延べられることから、課税関係は生じません。 ③ 当該ストックオプションを行使して取得した株式を売却した場合、株式譲渡益課税の対象 ...<br>
2. <a href="https://www.google.com/url?client=internal-element-cse&cx=002894216937212238947:kbug-tlua7u&q=https://www.nta.go.jp/law/tsutatsu/kobetsu/hojin/kaisei/kaisei4.htm&sa=U&ved=2ahUKEwiOjNGAwq-BAxU_pVYBHbcHBcUQFnoECAEQAQ&usg=AOvVaw1LAE8CMRZcPJdoeMfvW5Ie">法人課税関係の申請、届出等の様式の制定について 一部改正通達 ...</a><br>
法人課税関係の申請、届出等の様式の制定について 一部改正通達. 「法人課税関係の申請、届出等の様式の制定について」の一部改正について（令和5年6月30日） ...<br>
3. <a href="https://www.google.com/url?client=internal-element-cse&cx=002894216937212238947:kbug-tlua7u&q=https://www.nta.go.jp/law/tsutatsu/kihon/shohi/01.htm&sa=U&ved=2ahUKEwiOjNGAwq-BAxU_pVYBHbcHBcUQFnoECAYQAQ&usg=AOvVaw18F3uwn90k6tkH97FLmAIy">消費税法基本通達｜国税庁</a><br>
課税期間. 第1節 個人事業者の課税期間. 第2節 法人の課税期間. 第3節 課税期間の特例. 第4章 実質主義、信託財産に係る譲渡等の帰属. 第1節 実質主義. 第2節 信託財産に ...
<h2>「有識者DB」の検索結果</h2>
1. <a href="https://www.google.com/url?client=internal-element-cse&cx=002894216937212238947:kbug-tlua7u&q=https://www.nta.go.jp/law/tsutatsu/kihon/shotoku/kaisei/230707/pdf/02.pdf&sa=U&ved=2ahUKEwiOjNGAwq-BAxU_pVYBHbcHBcUQFnoECAcQAg&usg=AOvVaw0BXst6M2NwkkGf_TGfFNZO">令和 5 年5月 ストックオプションに対する課税（Q＆A）</a><br>
2023/07/07 ... により、課税が繰り延べられることから、課税関係は生じません。 ③ 当該ストックオプションを行使して取得した株式を売却した場合、株式譲渡益課税の対象 ...<br>
2. <a href="https://www.google.com/url?client=internal-element-cse&cx=002894216937212238947:kbug-tlua7u&q=https://www.nta.go.jp/law/tsutatsu/kobetsu/hojin/kaisei/kaisei4.htm&sa=U&ved=2ahUKEwiOjNGAwq-BAxU_pVYBHbcHBcUQFnoECAEQAQ&usg=AOvVaw1LAE8CMRZcPJdoeMfvW5Ie">法人課税関係の申請、届出等の様式の制定について 一部改正通達 ...</a><br>
法人課税関係の申請、届出等の様式の制定について 一部改正通達. 「法人課税関係の申請、届出等の様式の制定について」の一部改正について（令和5年6月30日） ...<br>
3. <a href="https://www.google.com/url?client=internal-element-cse&cx=002894216937212238947:kbug-tlua7u&q=https://www.nta.go.jp/law/tsutatsu/kihon/shohi/01.htm&sa=U&ved=2ahUKEwiOjNGAwq-BAxU_pVYBHbcHBcUQFnoECAYQAQ&usg=AOvVaw18F3uwn90k6tkH97FLmAIy">消費税法基本通達｜国税庁</a><br>
課税期間. 第1節 個人事業者の課税期間. 第2節 法人の課税期間. 第3節 課税期間の特例. 第4章 実質主義、信託財産に係る譲渡等の帰属. 第1節 実質主義. 第2節 信託財産に ...
<h2>生成された文章</h2>
以下に、株式の移転に関連するいくつかの重要な法的規定を示しますが、これはあくまで一例であり、全てを網羅しているわけではありません。<br>
法人税法第2条第1項:<br>
この条文は、法人税の対象となる所得の定義を提供します。株式の移転によって生じる所得も、この定義に基づき課税されます。<br>
所得税法第34条:<br>
この条文は、合併や株式交換、会社分割等に関する非課税処理の基本的な条件を規定しています。株式移転比率が時価でない場合、この非課税処理の適用を受けられない可能性があります。<br>
所得税法第37条:<br>
この条文は、合併に関する特別な課税処理を規定しています。株式移転比率が時価でない場合、この特別な課税処理の条件を満たさない可能性があります。<br>
所得税法第79条:<br>
この条文は、株式等の譲渡所得の計算方法を規定しています。株式の移転比率が時価でない場合、譲渡所得が発生し、この条文に基づく計算が必要になる可能性があります。<br>
日本の税法は非常に複雑であり、具体的なケースによって適用される法律や解釈が異なります。したがって、株式移転に関する税務処理の詳細については、必ず専門家のアドバイスを受けるようにしてください。税務署や税理士、弁護士などの専門家に相談することをお勧めします。<br>
'

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