import React, { useState } from "react";
import {
  ArrowRight,
  FileText,
  Download,
  Calendar,
  ArrowDownLeft,
  ArrowUpRight,
  RotateCw,
  Search
} from "lucide-react";
import { StatementEntry } from "../types";

interface Props {
  onBack: () => void;
  walletBalance: number;
}

export const AccountStatementScreen: React.FC<Props> = ({
  onBack,
  walletBalance,
}) => {
  const [searchTerm, setSearchTerm] = useState("");

  const entries: StatementEntry[] = [
    {
      id: "ST-901",
      date: "2026-09-09",
      time: "12:30 م",
      type: "payment",
      title: "تسديد باقة مزايا فولتي 48 ساعة",
      description: "تسديد للرقم 774952665 - يمن موبايل",
      debit: 600,
      credit: 0,
      balance: walletBalance,
      refNumber: "TX-7749001",
    },
    {
      id: "ST-900",
      date: "2026-09-09",
      time: "10:15 ص",
      type: "deposit",
      title: "إيداع وتغذية رصيد الحساب",
      description: "شحن رصيد نقدي عبر صرافة النجم - حوالة معتمدة",
      debit: 0,
      credit: 50000,
      balance: walletBalance + 600,
      refNumber: "DEP-884102",
    },
    {
      id: "ST-899",
      date: "2026-09-08",
      time: "08:45 م",
      type: "payment",
      title: "تسديد باقة سوبر فورجي الشهرية",
      description: "تسديد للرقم 771234567 - يمن فورجي",
      debit: 2000,
      credit: 0,
      balance: walletBalance + 600 - 50000 + 2000,
      refNumber: "TX-7748991",
    },
    {
      id: "ST-898",
      date: "2026-09-08",
      time: "04:20 م",
      type: "transfer_out",
      title: "تحويل رصيد لمشترك شوبك",
      description: "تحويل إلى المشترك محمد عبدالله الحيمي (771122334)",
      debit: 5000,
      credit: 0,
      balance: walletBalance + 600 - 50000 + 7000,
      refNumber: "GIFT-44102",
    },
  ];

  const filteredEntries = entries.filter((e) =>
    e.title.includes(searchTerm) ||
    e.description.includes(searchTerm) ||
    e.refNumber.includes(searchTerm)
  );

  return (
    <div className="flex-1 flex flex-col bg-[#F8FAFC] overflow-hidden">
      {/* Top Header */}
      <div className="bg-[#8B1D3B] text-white px-4 py-3.5 flex items-center justify-between shadow-md">
        <div className="flex items-center gap-2">
          <button
            onClick={onBack}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/20 hover:bg-white/30 text-white transition active:scale-95 text-xs font-black shadow-xs border border-white/20"
            title="العودة إلى واجهة حسابي الرئيسية"
          >
            <ArrowRight className="w-4 h-4" />
            <span>حسابي</span>
          </button>
          <div className="font-black text-base">كشف حساب العميل</div>
        </div>

        <button
          onClick={() => alert("جاري تحميل كشف الحساب كملف PDF...")}
          className="w-9 h-9 rounded-full bg-white/15 hover:bg-white/25 flex items-center justify-center transition"
          title="تصدير كشف الحساب"
        >
          <Download className="w-4 h-4 text-white" />
        </button>
      </div>

      {/* Account Overview Card */}
      <div className="p-3 bg-white border-b border-slate-200 shadow-sm space-y-2">
        <div className="flex items-center justify-between">
          <div>
            <div className="text-[11px] font-bold text-slate-400">الرصيد الختامي الحالي</div>
            <div className="text-xl font-black text-[#8B1D3B]">
              {walletBalance.toLocaleString()} ر.ي
            </div>
          </div>
          <div className="text-left text-xs font-bold text-slate-600">
            <div>العميل: زيدان العطاب</div>
            <div className="text-slate-400 text-[10px]">الحساب: 774952665</div>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="بحث في قيود كشف الحساب..."
            className="w-full bg-slate-100 rounded-xl px-3 py-2 pr-9 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#8B1D3B]"
          />
          <Search className="w-4 h-4 text-slate-400 absolute right-3 top-2.5" />
        </div>
      </div>

      {/* Ledger List */}
      <div className="flex-1 overflow-y-auto p-3 space-y-2">
        {filteredEntries.map((entry, idx) => {
          const isDeposit = entry.credit > 0;
          return (
            <div
              key={entry.id ? `stmt-entry-${entry.id}-${idx}` : `stmt-entry-${idx}`}
              className="bg-white rounded-2xl p-3 border border-slate-200 shadow-sm space-y-1.5"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div
                    className={`w-8 h-8 rounded-xl flex items-center justify-center ${
                      isDeposit ? "bg-emerald-100 text-emerald-700" : "bg-rose-100 text-[#8B1D3B]"
                    }`}
                  >
                    {isDeposit ? (
                      <ArrowDownLeft className="w-4 h-4" />
                    ) : (
                      <ArrowUpRight className="w-4 h-4" />
                    )}
                  </div>
                  <div>
                    <div className="text-xs font-black text-slate-800">{entry.title}</div>
                    <div className="text-[10px] text-slate-400">{entry.date} {entry.time}</div>
                  </div>
                </div>

                <div className="text-left">
                  <div
                    className={`text-sm font-black ${
                      isDeposit ? "text-emerald-600" : "text-[#8B1D3B]"
                    }`}
                  >
                    {isDeposit ? `+${entry.credit.toLocaleString()}` : `-${entry.debit.toLocaleString()}`} ر.ي
                  </div>
                  <div className="text-[10px] text-slate-400 font-bold">
                    الرصيد: {entry.balance.toLocaleString()}
                  </div>
                </div>
              </div>

              <div className="pt-1.5 border-t border-slate-100 flex items-center justify-between text-[10px] text-slate-500 font-semibold">
                <span className="line-clamp-1">{entry.description}</span>
                <span className="font-mono text-slate-400 shrink-0">#{entry.refNumber}</span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
