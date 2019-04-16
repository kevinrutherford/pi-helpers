# Copyright (c) Piford Software Limited - All Rights Reserved.
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
#

require 'pi_helpers/util/principal'

RSpec.describe Pi::Util::Principal do
  let(:user_id) { random_id }
  let(:company_id) { random_id }
  let(:start_time) { (Time.now - 27).to_i }
  let(:end_time) { (Time.now + 27).to_i }
  let(:claims) {
    {
      'jti' => random_id,
      'iat' => start_time,
      'exp' => end_time,
      'userId' => user_id,
      'emailAddress' => random_word,
      'companyId' => company_id,
      'privileges' => ['create_nuttshells', 'manage_colleagues']
    }
  }
  subject { Pi::Util::Principal.new(claims) }

  it 'reports the user id' do
    expect(subject.user_id).to eq(user_id)
  end

  it 'reports the company id' do
    expect(subject.company_id).to eq(company_id)
  end

  it 'reports the creation and expiry times' do
    expect(subject.created_at).to eq(start_time)
    expect(subject.expires_at).to eq(end_time)
  end

  it 'reports privileges correctly' do
    expect(subject.can('manage_colleagues')).to be true
    expect(subject.can(:manage_colleagues)).to be true
    expect(subject.can('create_templates')).to be false
    expect(subject.can(:create_templates)).to be false
  end

end

