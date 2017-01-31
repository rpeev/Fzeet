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
		TVS_HASBUTTONS = 0x0001
		TVS_HASLINES = 0x0002
		TVS_LINESATROOT = 0x0004
		TVS_EDITLABELS = 0x0008
		TVS_DISABLEDRAGDROP = 0x0010
		TVS_SHOWSELALWAYS = 0x0020
		TVS_RTLREADING = 0x0040
		TVS_NOTOOLTIPS = 0x0080
		TVS_CHECKBOXES = 0x0100
		TVS_TRACKSELECT = 0x0200
		TVS_SINGLEEXPAND = 0x0400
		TVS_INFOTIP = 0x0800
		TVS_FULLROWSELECT = 0x1000
		TVS_NOSCROLL = 0x2000
		TVS_NONEVENHEIGHT = 0x4000
		TVS_NOHSCROLL = 0x8000

		TVS_EX_MULTISELECT = 0x0002
		TVS_EX_DOUBLEBUFFER = 0x0004
		TVS_EX_NOINDENTSTATE = 0x0008
		TVS_EX_RICHTOOLTIP = 0x0010
		TVS_EX_AUTOHSCROLL = 0x0020
		TVS_EX_FADEINOUTEXPANDOS = 0x0040
		TVS_EX_PARTIALCHECKBOXES = 0x0080
		TVS_EX_EXCLUSIONCHECKBOXES = 0x0100
		TVS_EX_DIMMEDCHECKBOXES = 0x0200
		TVS_EX_DRAWIMAGEASYNC = 0x0400

		TV_FIRST = 0x1100

		TVM_INSERTITEM = TV_FIRST + 0
		TVM_DELETEITEM = TV_FIRST + 1
		TVM_EXPAND = TV_FIRST + 2
		TVM_GETITEMRECT = TV_FIRST + 4
		TVM_GETCOUNT = TV_FIRST + 5
		TVM_GETINDENT = TV_FIRST + 6
		TVM_SETINDENT = TV_FIRST + 7
		TVM_GETIMAGELIST = TV_FIRST + 8
		TVM_SETIMAGELIST = TV_FIRST + 9
		TVM_GETNEXTITEM = TV_FIRST + 10
		TVM_SELECTITEM = TV_FIRST + 11
		TVM_GETITEM = TV_FIRST + 12
		TVM_SETITEM = TV_FIRST + 13
		TVM_EDITLABEL = TV_FIRST + 14
		TVM_GETEDITCONTROL = TV_FIRST + 15
		TVM_GETVISIBLECOUNT = TV_FIRST + 16
		TVM_HITTEST = TV_FIRST + 17
		TVM_CREATEDRAGIMAGE = TV_FIRST + 18
		TVM_SORTCHILDREN = TV_FIRST + 19
		TVM_ENSUREVISIBLE = TV_FIRST + 20
		TVM_SORTCHILDRENCB = TV_FIRST + 21
		TVM_ENDEDITLABELNOW = TV_FIRST + 22
		TVM_GETISEARCHSTRING = TV_FIRST + 23
		TVM_SETTOOLTIPS = TV_FIRST + 24
		TVM_GETTOOLTIPS = TV_FIRST + 25
		TVM_SETINSERTMARK = TV_FIRST + 26
		TVM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		TVM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT
		TVM_SETITEMHEIGHT = TV_FIRST + 27
		TVM_GETITEMHEIGHT = TV_FIRST + 28
		TVM_SETBKCOLOR = TV_FIRST + 29
		TVM_SETTEXTCOLOR = TV_FIRST + 30
		TVM_GETBKCOLOR = TV_FIRST + 31
		TVM_GETTEXTCOLOR = TV_FIRST + 32
		TVM_SETSCROLLTIME = TV_FIRST + 33
		TVM_GETSCROLLTIME = TV_FIRST + 34
		TVM_SETINSERTMARKCOLOR = TV_FIRST + 37
		TVM_GETINSERTMARKCOLOR = TV_FIRST + 38
		TVM_GETITEMSTATE = TV_FIRST + 39
		TVM_SETLINECOLOR = TV_FIRST + 40
		TVM_GETLINECOLOR = TV_FIRST + 41
		TVM_MAPACCIDTOHTREEITEM = TV_FIRST + 42
		TVM_MAPHTREEITEMTOACCID = TV_FIRST + 43
		TVM_SETEXTENDEDSTYLE = TV_FIRST + 44
		TVM_GETEXTENDEDSTYLE = TV_FIRST + 45
		TVM_SETAUTOSCROLLINFO = TV_FIRST + 59
		TVM_GETSELECTEDCOUNT = TV_FIRST + 70
		TVM_SHOWINFOTIP = TV_FIRST + 71
		TVM_GETITEMPARTRECT = TV_FIRST + 72

		TVN_FIRST = 0x1_0000_0000 - 400
		TVN_LAST = 0x1_0000_0000 - 499
		TVN_SELCHANGING = TVN_FIRST - 1
		TVN_SELCHANGED = TVN_FIRST - 2
		TVN_GETDISPINFO = TVN_FIRST - 3
		TVN_SETDISPINFO = TVN_FIRST - 4
		TVN_ITEMEXPANDING = TVN_FIRST - 5
		TVN_ITEMEXPANDED = TVN_FIRST - 6
		TVN_BEGINDRAG = TVN_FIRST - 7
		TVN_BEGINRDRAG = TVN_FIRST - 8
		TVN_DELETEITEM = TVN_FIRST - 9
		TVN_BEGINLABELEDIT = TVN_FIRST - 10
		TVN_ENDLABELEDIT = TVN_FIRST - 11
		TVN_KEYDOWN = TVN_FIRST - 12
		TVN_GETINFOTIP = TVN_FIRST - 13
		TVN_SINGLEEXPAND = TVN_FIRST - 15
		TVN_ITEMCHANGING = TVN_FIRST - 16
		TVN_ITEMCHANGED = TVN_FIRST - 18
		TVN_ASYNCDRAW = TVN_FIRST - 20

		TVIF_TEXT = 0x0001
		TVIF_IMAGE = 0x0002
		TVIF_PARAM = 0x0004
		TVIF_STATE = 0x0008
		TVIF_HANDLE = 0x0010
		TVIF_SELECTEDIMAGE = 0x0020
		TVIF_CHILDREN = 0x0040
		TVIF_INTEGRAL = 0x0080
		TVIF_STATEEX = 0x0100
		TVIF_EXPANDEDIMAGE = 0x0200

		TVIS_SELECTED = 0x0002
		TVIS_CUT = 0x0004
		TVIS_DROPHILITED = 0x0008
		TVIS_BOLD = 0x0010
		TVIS_EXPANDED = 0x0020
		TVIS_EXPANDEDONCE = 0x0040
		TVIS_EXPANDPARTIAL = 0x0080
		TVIS_OVERLAYMASK = 0x0F00
		TVIS_STATEIMAGEMASK = 0xF000
		TVIS_USERMASK = 0xF000

		TVIS_EX_FLAT = 0x0001
		TVIS_EX_DISABLED = 0x0002
		TVIS_EX_ALL = 0x0002

		I_CHILDRENCALLBACK = -1

		class TVITEM < FFI::Struct
			layout \
				:mask, :uint,
				:hItem, :pointer,
				:state, :uint,
				:stateMask, :uint,
				:pszText, :pointer,
				:cchTextMax, :int,
				:iImage, :int,
				:iSelectedImage, :int,
				:cChildren, :int,
				:lParam, :long
		end

		class TVITEMEX < FFI::Struct
			layout(*[
				:mask, :uint,
				:hItem, :pointer,
				:state, :uint,
				:stateMask, :uint,
				:pszText, :pointer,
				:cchTextMax, :int,
				:iImage, :int,
				:iSelectedImage, :int,
				:cChildren, :int,
				:lParam, :long,
				:iIntegral, :int,
				(Version >= :vista) ? [
					:uStateEx, :uint,
					:hwnd, :pointer,
					:iExpandedImage, :int
				] : nil,
				(Version >= 7) ? [
					:iReserved, :int
				] : nil
			].flatten.compact)
		end

		TVI_ROOT = FFI::Pointer.new(-0x10000)
		TVI_FIRST = FFI::Pointer.new(-0x0FFFF)
		TVI_LAST = FFI::Pointer.new(-0x0FFFE)
		TVI_SORT = FFI::Pointer.new(-0x0FFFD)

		class TVINSERTSTRUCT < FFI::Struct
			include AnonymousSupport

			layout \
				:hParent, :pointer,
				:hInsertAfter, :pointer,
				:_, Class.new(FFI::Union) {
					layout \
						:itemex, TVITEMEX,
						:item, TVITEM
				}
		end

		class NMTREEVIEW < FFI::Struct
			layout \
				:hdr, NMHDR,
				:action, :uint,
				:itemOld, TVITEM,
				:itemNew, TVITEM,
				:ptDrag, POINT
		end
	end

	module TreeViewMethods
		class Item
			def initialize(text) @text = text end

			attr_reader :text, :root, :parent, :handle

			def root=(root) raise 'Can\'t change established @root.' if @root; @root = root end
			def parent=(parent) raise 'Can\'t change established @parent.' if @parent; @parent = parent end
			def handle=(handle) raise 'Can\'t change established @handle.' if @handle; @handle = handle end

			def append(text)
				item = Item.new(text)

				tvis = Windows::TVINSERTSTRUCT.new

				tvis[:hInsertAfter] = Windows::TVI_LAST
				tvis[:hParent] = @handle

				tvi = tvis[:item]

				tvi[:mask] = Windows::TVIF_TEXT
				tvi[:pszText] = ptext = FFI::MemoryPointer.from_string(item.text)

				item.root, item.parent = @root, self
				item.handle = @root.sendmsg(:insertitem, 0, tvis.pointer)

				item
			ensure
				ptext.free
			end
		end

		def append(text)
			item = Item.new(text)

			tvis = Windows::TVINSERTSTRUCT.new

			tvis[:hInsertAfter] = Windows::TVI_LAST
			tvis[:hParent] = Windows::TVI_ROOT

			tvi = tvis[:item]

			tvi[:mask] = Windows::TVIF_TEXT
			tvi[:pszText] = ptext = FFI::MemoryPointer.from_string(item.text)

			item.root, item.parent = self, self
			item.handle = sendmsg(:insertitem, 0, tvis.pointer)

			item
		ensure
			ptext.free
		end
	end

	class TreeView < Control
		include TreeViewMethods

		Prefix = {
			xstyle: [:tvs_ex, :ws_ex_],
			style: [:tvs_, :ws_],
			message: [:tvm_, :ccm_, :wm_],
			notification: [:tvn_, :nm_]
		}

		def self.crackNotification(args) end

		def initialize(parent, id, opts = {}, &block)
			super('SysTreeView32', parent, id, opts)

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
