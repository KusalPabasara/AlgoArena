import { Heart, MessageCircle, Send, Bookmark, Home, Search, Calendar, Diamond, User, Bell } from "lucide-react";
import leoLogo from "figma:asset/dadf4d4416619e27f6568729d8ba88e30310002f.png";
import postImage from "figma:asset/5e1dd65ca0c4106010fd33a3f7c80497f02ca5b2.png";
import avatarImage from "figma:asset/c6d5f9dff52b37a28977be041de113bc88dfa388.png";
import notificationIcon from "figma:asset/46c0a1257767ee4cd7ad3210f3115442910dffb2.png";

export default function FeedApp() {
  return (
    <div className="min-h-screen bg-white flex flex-col max-w-[400px] mx-auto">
      {/* Status Bar */}
      <div className="flex items-center justify-between px-6 py-3 text-sm">
        <span className="font-semibold">9:41</span>
        <div className="flex items-center gap-1">
          <svg width="17" height="12" viewBox="0 0 17 12" fill="none">
            <rect x="0.5" y="0.5" width="3" height="11" rx="0.5" fill="black"/>
            <rect x="5" y="2" width="3" height="10" rx="0.5" fill="black"/>
            <rect x="9.5" y="3.5" width="3" height="8.5" rx="0.5" fill="black"/>
            <rect x="14" y="5" width="3" height="7" rx="0.5" fill="black"/>
          </svg>
          <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
            <path d="M8 0C6.12 0 4.32 0.63 2.88 1.68C4.32 2.73 5.76 4.2 6.72 6C7.68 4.2 9.12 2.73 10.56 1.68C9.12 0.63 7.32 0 8 0ZM0 3.6C0 2.16 0.72 0.84 1.92 0C0.72 1.08 0 2.52 0 4.08C0 5.64 0.72 7.08 1.92 8.16C0.72 7.32 0 6 0 4.56V3.6ZM13.44 1.68C14.88 2.73 16 4.68 16 6.84C16 9 14.88 10.92 13.44 12C14.88 10.92 16 9 16 6.84C16 4.68 14.88 2.73 13.44 1.68Z" fill="black"/>
          </svg>
          <svg width="25" height="12" viewBox="0 0 25 12" fill="none">
            <rect x="0.5" y="0.5" width="18" height="11" rx="2" stroke="black" strokeOpacity="0.35"/>
            <rect x="2" y="2" width="15" height="8" rx="1" fill="black"/>
            <rect x="20" y="4" width="4" height="4" rx="1" fill="black" fillOpacity="0.4"/>
          </svg>
        </div>
      </div>

      {/* Header */}
      <div className="border-b border-gray-200 px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <img src={leoLogo} alt="Leo Logo" className="h-12" />
        </div>
        <div className="flex items-center gap-4">
          <button className="hover:bg-gray-50 rounded-full p-1">
            <Bell className="w-6 h-6 text-black" />
          </button>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="3" y1="12" x2="21" y2="12" />
            <line x1="3" y1="6" x2="21" y2="6" />
            <line x1="3" y1="18" x2="21" y2="18" />
          </svg>
        </div>
      </div>

      {/* Feed Content */}
      <div className="flex-1 overflow-y-auto">
        {/* Post */}
        <div className="border-b border-gray-100">
          {/* Post Header */}
          <div className="flex items-center justify-between px-4 py-3">
            <div className="flex items-center gap-3">
              <img 
                src={avatarImage} 
                alt="Leo Club of Colombo" 
                className="w-10 h-10 rounded-full object-cover"
              />
              <div>
                <p className="font-semibold text-sm">Leo Club of Colombo</p>
                <p className="text-xs text-gray-500">8 hours ago</p>
              </div>
            </div>
            <button className="text-gray-600">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <circle cx="10" cy="4" r="1.5" />
                <circle cx="10" cy="10" r="1.5" />
                <circle cx="10" cy="16" r="1.5" />
              </svg>
            </button>
          </div>

          {/* Post Image */}
          <div className="w-full">
            <img 
              src={postImage} 
              alt="Your turn to lead" 
              className="w-full h-auto object-cover"
            />
          </div>

          {/* Post Actions */}
          <div className="px-4 py-3">
            <div className="flex items-center justify-between mb-2">
              <div className="flex items-center gap-4">
                <button className="hover:text-gray-600">
                  <Heart className="w-6 h-6" />
                </button>
                <button className="hover:text-gray-600">
                  <MessageCircle className="w-6 h-6" />
                </button>
                <button className="hover:text-gray-600">
                  <Send className="w-6 h-6" />
                </button>
              </div>
              <button className="hover:text-gray-600">
                <Bookmark className="w-6 h-6" />
              </button>
            </div>

            {/* Likes */}
            <p className="font-semibold text-sm mb-1">2156 likes</p>

            {/* Caption */}
            <p className="text-sm">
              <span className="font-semibold">john_d</span>{" "}
              <span className="text-gray-800">City lights and urban nights ✨</span>
            </p>

            {/* View Comments */}
            <button className="text-sm text-gray-500 mt-1">
              View all 67 comments
            </button>
          </div>
        </div>
      </div>

      {/* Bottom Navigation */}
      <div className="border-t border-gray-200 px-6 py-3 flex items-center justify-around bg-white">
        <button className="p-2 rounded-full bg-yellow-400">
          <Home className="w-6 h-6 text-black" fill="black" />
        </button>
        <button className="p-2 hover:bg-gray-100 rounded-full">
          <Search className="w-6 h-6 text-black" />
        </button>
        <button className="p-2 hover:bg-gray-100 rounded-full">
          <Calendar className="w-6 h-6 text-black" />
        </button>
        <button className="p-2 hover:bg-gray-100 rounded-full">
          <Diamond className="w-6 h-6 text-black" />
        </button>
        <button className="p-2 hover:bg-gray-100 rounded-full">
          <User className="w-6 h-6 text-black" />
        </button>
      </div>

      {/* Home Indicator (iOS style) */}
      <div className="h-6 flex items-center justify-center">
        <div className="w-32 h-1 bg-black rounded-full"></div>
      </div>
    </div>
  );
}