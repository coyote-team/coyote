require "spec_helper"

RSpec.xdescribe ProcessImportWorker do
  let(:import) { create(:import) }

  it "paginates processing" do
    allow(ProcessImportWorker).to receive(:perform_async).with(import.id).times(6)
    ProcessImportWorker.perform_async(import.id)
  end
end
