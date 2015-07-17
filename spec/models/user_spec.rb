require 'spec_helper'

describe User do #クラスを渡してクラスのテストをしている

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "名前が存在しない場合" do
  	before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "電子メールは存在しない場合" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "名前の長さの確認" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "電子メールの形式が無効な時" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "電子メールの形式が有効な時" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "電子メールアドレスが、すでに存在している時" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "パスワードが存在しない時" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "パスワードが一致しない時" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "パスワードが短すぎる" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end


  describe "認証メソッドの戻り値" do
  	before { @user.save }
 	let(:found_user) { User.find_by(email: @user.email) }

 	 describe "有効なパスワードを持ちました" do
   		it { should eq found_user.authenticate(@user.password) }
  	 end

	  describe "無効なパスワードを使用して、" do
	    let(:user_for_invalid_password) { found_user.authenticate("invalid") }

	    it { should_not eq user_for_invalid_password }
	    specify { expect(user_for_invalid_password).to be_false }
	  end

  end


end
