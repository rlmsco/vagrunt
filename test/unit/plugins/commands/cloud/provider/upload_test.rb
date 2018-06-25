require File.expand_path("../../../../../base", __FILE__)

require Vagrant.source_root.join("plugins/commands/cloud/provider/upload")

describe VagrantPlugins::CloudCommand::ProviderCommand::Command::Upload do
  include_context "unit"

  let(:argv)     { [] }
  let(:iso_env) do
    # We have to create a Vagrantfile so there is a root path
    env = isolated_environment
    env.vagrantfile("")
    env.create_vagrant_env
  end

  subject { described_class.new(argv, iso_env) }

  let(:action_runner) { double("action_runner") }

  let(:client) { double("client", token: "1234token1234") }
  let(:box) { double("box") }
  let(:version) { double("version") }
  let(:provider) { double("provider") }

  before do
    allow(iso_env).to receive(:action_runner).and_return(action_runner)
    allow(VagrantPlugins::CloudCommand::Util).to receive(:client_login).
      and_return(client)
    allow(VagrantPlugins::CloudCommand::Util).to receive(:format_box_results).
      and_return(true)
    allow(VagrantCloud::Box).to receive(:new)
      .with(anything, "box-name", nil, nil, nil, client.token)
      .and_return(box)
    allow(VagrantCloud::Version).to receive(:new)
      .with(box, "1.0.0", nil, nil, client.token)
      .and_return(version)
  end

  context "with no arguments" do
    it "shows help" do
      expect { subject.execute }.
        to raise_error(Vagrant::Errors::CLIInvalidUsage)
    end
  end

  context "with arguments" do
    let (:argv) { ["vagrant/box-name", "virtualbox", "1.0.0", "path/to/box.box"] }

    it "uploads a provider" do
      allow(VagrantCloud::Provider).to receive(:new).
        with(version, "virtualbox", nil, nil, "vagrant", "box-name", client.token).
        and_return(provider)

      expect(provider).to receive(:upload_file).
        with("path/to/box.box").
        and_return({})
      expect(subject.execute).to eq(0)
    end

    it "displays an error if encoutering a problem with the request" do
      allow(VagrantCloud::Provider).to receive(:new).
        with(version, "virtualbox", nil, nil, "vagrant", "box-name", client.token).
        and_return(provider)

      allow(provider).to receive(:upload_file).
        and_raise(VagrantCloud::ClientError.new("Fail Message", "Message"))
      expect(subject.execute).to eq(1)
    end
  end
end
