require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	UIRibbon.new(window).
		on(CmdButton1) { message 'on(CmdButton1)' }.
		on(CmdSplit1) { message 'on(CmdSplit1)' }.
		on(CmdToggle1) { window.ribbon[CmdCheck1].toggle(:checked) }.
		on(CmdCheck1) { window.ribbon[CmdToggle1].toggle(:checked) }.

		on(CmdHelp) { message 'on(CmdHelp)' }

	window.ribbon[CmdToggle1].checked = true

	window.
		on(:draw, Control::Font) { |dc| dc.sms 'Right-click (or menu key) for context menu' }.

		on(:contextmenu) { |args|
			window.ribbon.contextualUI(CmdContextMap1, args[:x], args[:y])
		}
}
