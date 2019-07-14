# ISUCON8 予選問題用環境(terraformで作れるよ)


## terraformでサーバ構築

### 事前準備

* aws-cli
  * aws configureで利用するawsアカウントの情報を突っ込んどいてください。
* terraform(私はv0.12を使っています。)
* ansible(私はdirenv + venv で環境分離して利用しています。 direnv + venv の参考 https://www.greptips.com/posts/1281/ )
* git

```bash
git clone --recursive https://github.com/fk1jp/isucon2018-qualify.git /usr/local/isucon2018-p_infra
cd /usr/local/isucon2018-p_infra
cd terraform
terraform init

cp -pi terraform.tfvars.tmp terraform.tfvars
vim terraform.tfvars
  # 必要な情報を入力。
  # [your ip]のところはアクセス元のipを登録してください。

# VPCのprivate ip のレンジを10.123.0.0/16にしてるんですけど、嫌だったらmain.tf内の10.123って書いてる箇所を書き換えてもらえればいいですよ。
```

### サーバ構築
```bash
terraform plan
terraform apply
  # CentOS7のAMIをsubscribeしてないとコケるので、awsログイン済みのブラウザでエラーログに出てきたURL叩いて、subscribeしてください。
terraform apply
  # server01-03に関してはansible実行時に色々とbuildしたりするので、ansible流す時だけスペックをちょっと(t3.smallくらい)上げておいたほうが良さげ
  # ansible流し終わったらスペック下げましょう。(EIPつけていないので、再起動するたびにグローバル側のIPが変わるのでご注意を)

cd ..
pwd
  # /usr/local/isucon2018-p_infraであることを確認 
```

### サーバ情報取得
```bash
aws ec2 describe-instances | jq -c '.Reservations[].Instances[] | select(.Tags[].Key == "Name") | .PublicIpAddress + " " + .Tags[].Value '
```
上記出力を/etc/hostsに追記

### ansible実行
```bash
cd isucon8-qualify/provisioning/
vim webapp1.yml
  # install_[自分が使う言語]とinstall_perl 以外の install_hoge はコメントアウトしたほうが早い(prepare_webappでコケるため、今は全部のせにしましょう。)
  # webapp1 は最初にperlのサンプルプログラムが走るので、perlは使わないにしてもインストールは必須

vim webapp2.yml
vim webapp3.yml
  # install_[自分が使う言語] 以外の install_hoge はコメントアウトしたほうが早い(prepare_webappでコケるため、今は全部のせにしましょう。)

ansible-playbook -i development site.yml
```

以上でセッティングできてるはず！
なんかあったら連絡ください。
