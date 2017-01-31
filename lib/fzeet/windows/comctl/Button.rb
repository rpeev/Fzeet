if __FILE__ == $0
	require 'ffi'

	# FIXME: dirty fix to propagate FFI structs layout down the inheritance hierarchy
	# TODO: switch to composition instead inheriting FFI structs
	module PropagateFFIStructLayout
		def inherited(child_class)
			child_class.instance_variable_set '@layout', layout
		end
	end

	class FFI::Struct
		def self.inherited(child_class)
			child_class.extend PropagateFFIStructLayout
		end
	end
	# END FIXME
end

require_relative 'Common'

module Fzeet
	module Windows
		BS_SPLITBUTTON = 0x0000000C
		BS_DEFSPLITBUTTON = 0x0000000D
		BS_COMMANDLINK = 0x0000000E
		BS_DEFCOMMANDLINK = 0x0000000F

		BCM_FIRST = 0x1600
		BCM_GETIDEALSIZE = BCM_FIRST + 0x0001
		BCM_SETIMAGELIST = BCM_FIRST + 0x0002
		BCM_GETIMAGELIST = BCM_FIRST + 0x0003
		BCM_SETTEXTMARGIN = BCM_FIRST + 0x0004
		BCM_GETTEXTMARGIN = BCM_FIRST + 0x0005
		BCM_SETDROPDOWNSTATE = BCM_FIRST + 0x0006
		BCM_SETSPLITINFO = BCM_FIRST + 0x0007
		BCM_GETSPLITINFO = BCM_FIRST + 0x0008
		BCM_SETNOTE = BCM_FIRST + 0x0009
		BCM_GETNOTE = BCM_FIRST + 0x000A
		BCM_GETNOTELENGTH = BCM_FIRST + 0x000B
		BCM_SETSHIELD = BCM_FIRST + 0x000C

		BST_HOT = 0x0200
		BST_DROPDOWNPUSHED = 0x0400

		BCN_FIRST = 0x1_0000_0000 - 1250
		BCN_LAST = 0x1_0000_0000 - 1350
		BCN_HOTITEMCHANGE = BCN_FIRST + 0x0001
		BCN_DROPDOWN = BCN_FIRST + 0x0002
		NM_GETCUSTOMSPLITRECT = BCN_FIRST + 0x0003
	end
end
