require File.join(File.dirname(__FILE__), '../../test_helper')
require 'hammer_cli_katello/content_view_version'

describe 'content-view version export-future' do
  include ForemanTaskHelpers

  before do
    @cmd = %w(content-view version export-future)
  end

  let(:task_id) { '5' }
  let(:response) do
    {
      'id' => task_id,
      'state' => 'planned'
    }
  end

  it "performs export with required options" do
    params = [
      '--id=2',
      '--destination-server=foo'
    ]

    ex = api_expects(:content_view_versions, :export)
    ex.returns(response)

    expect_foreman_task('5')

    result = run_cmd(@cmd + params)
    assert_equal(HammerCLI::EX_OK, result.exit_code)
  end

  it 'fails on missing required params' do
    params = [
      '--id=2'
    ]

    result = run_cmd(@cmd + params)
    expected_error = "Could not export the content view version:\n"

    assert_equal(result.exit_code, HammerCLI::EX_USAGE)
    assert_equal(result.err[/#{expected_error}/], expected_error)
  end
end
