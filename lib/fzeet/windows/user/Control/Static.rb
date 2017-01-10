require_relative 'Common'

module Fzeet
	module Windows
		SS_LEFT = 0x00000000
		SS_CENTER = 0x00000001
		SS_RIGHT = 0x00000002
		SS_ICON = 0x00000003
		SS_BLACKRECT = 0x00000004
		SS_GRAYRECT = 0x00000005
		SS_WHITERECT = 0x00000006
		SS_BLACKFRAME = 0x00000007
		SS_GRAYFRAME = 0x00000008
		SS_WHITEFRAME = 0x00000009
		SS_USERITEM = 0x0000000A
		SS_SIMPLE = 0x0000000B
		SS_LEFTNOWORDWRAP = 0x0000000C
		SS_OWNERDRAW = 0x0000000D
		SS_BITMAP = 0x0000000E
		SS_ENHMETAFILE = 0x0000000F
		SS_ETCHEDHORZ = 0x00000010
		SS_ETCHEDVERT = 0x00000011
		SS_ETCHEDFRAME = 0x00000012
		SS_TYPEMASK = 0x0000001F
		SS_REALSIZECONTROL = 0x00000040
		SS_NOPREFIX = 0x00000080
		SS_NOTIFY = 0x00000100
		SS_CENTERIMAGE = 0x00000200
		SS_RIGHTJUST = 0x00000400
		SS_REALSIZEIMAGE = 0x00000800
		SS_SUNKEN = 0x00001000
		SS_EDITCONTROL = 0x00002000
		SS_ENDELLIPSIS = 0x00004000
		SS_PATHELLIPSIS = 0x00008000
		SS_WORDELLIPSIS = 0x0000C000
		SS_ELLIPSISMASK = 0x0000C000

		STM_SETICON = 0x0170
		STM_GETICON = 0x0171
		STM_SETIMAGE = 0x0172
		STM_GETIMAGE = 0x0173
		STM_MSGMAX = 0x0174

		STN_CLICKED = 0
		STN_DBLCLK = 1
		STN_ENABLE = 2
		STN_DISABLE = 3
	end

	module StaticMethods
		def clear; self.text = ''; self end

		def image=(image) sendmsg(:setimage, Windows::IMAGE_BITMAP, image.handle) end
	end

	class Static < Control
		include StaticMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:ss_, :ws_],
			message: [:stm_, :wm_],
			notification: [:stn_]
		}

		def initialize(parent, id, opts = {}, &block)
			super('Static', parent, id, opts)

			style >> :tabstop

			@parent.on(:command, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:command, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
