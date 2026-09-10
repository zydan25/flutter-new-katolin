import React, { useState } from "react";
import {
  ArrowRight,
  BarChart3,
  TrendingUp,
  Calendar,
  Layers,
  ArrowUpRight,
  CheckCircle2,
  Filter,
  PieChart
} from "lucide-react";

interface Props {
  onBack: () => void;
}

export const ReportsScreen: React.FC<Props> = ({ onBack }) => {
  const [period, setPeriod] = useState<"today" | "week" | "month">("today");

  const stats = {
    today: {
      sales: 58240,
      commissions: 1456,
      count: 42,
      successRate: 99.2,
    },
    week: {
      sales: 342100,
      commissions: 8550,
      count: 248,
      successRate: 99.4,
    },
    month: {
      sales: 1420500,
      commissions: 35512,
      count: 1040,
      successRate: 99.6,
    },
  }[period];

  const operatorBreakdown = [
    { name: "يمن موبايل", percentage: 68, amount: stats.sales * 0.68, color: "bg-[#8B1D3B]" },
    { name: "يو (YOU)", percentage: 18, amount: stats.sales * 0.18, color: "bg-[#F59E0B]" },
    { name: "سبأفون", percentage: 10, amount: stats.sales * 0.10, color: "bg-[#1E88E5]" },
    { name: "يمن 4G و ADSL", percentage: 4, amount: stats.sales * 0.04, color: "bg-[#0284C7]" },
  ];

  return (
    <div className="flex-1 flex flex-col bg-[#F8FAFC] overflow-y-auto">
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
          <div className="font-black text-base">التقارير المالية والمبيعات</div>
        </div>

        <div className="w-9 h-9 rounded-full bg-white/15 flex items-center justify-center">
          <BarChart3 className="w-5 h-5 text-white" />
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Period Selector */}
        <div className="flex bg-white p-1 rounded-2xl border border-slate-200 shadow-sm gap-1 text-xs font-black">
          {[
            { id: "today", label: "اليوم" },
            { id: "week", label: "هذا الأسبوع" },
            { id: "month", label: "هذا الشهر" },
          ].map((item) => (
            <button
              key={`report-period-${item.id}`}
              onClick={() => setPeriod(item.id as any)}
              className={`flex-1 py-2 rounded-xl transition text-center ${
                period === item.id
                  ? "bg-[#8B1D3B] text-white shadow-sm"
                  : "text-slate-600 hover:bg-slate-100"
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>

        {/* Hero Cards Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-white rounded-2xl p-3.5 border border-slate-200 shadow-sm">
            <div className="text-[11px] font-bold text-slate-400 mb-1">إجمالي المبيعات</div>
            <div className="text-lg font-black text-slate-900">
              {stats.sales.toLocaleString()} ر.ي
            </div>
            <div className="text-[10px] text-emerald-600 font-bold flex items-center gap-1 mt-1">
              <TrendingUp className="w-3 h-3" />
              <span>معدل نمو مستقر</span>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-3.5 border border-slate-200 shadow-sm">
            <div className="text-[11px] font-bold text-slate-400 mb-1">صافي الأرباح والعمولات</div>
            <div className="text-lg font-black text-emerald-600">
              {stats.commissions.toLocaleString()} ر.ي
            </div>
            <div className="text-[10px] text-slate-400 font-semibold mt-1">
              أرباح فورية مضافة
            </div>
          </div>

          <div className="bg-white rounded-2xl p-3.5 border border-slate-200 shadow-sm">
            <div className="text-[11px] font-bold text-slate-400 mb-1">عدد العمليات</div>
            <div className="text-lg font-black text-slate-900">
              {stats.count} عملية
            </div>
            <div className="text-[10px] text-blue-600 font-bold mt-1">
              جميعها من السيرفر
            </div>
          </div>

          <div className="bg-white rounded-2xl p-3.5 border border-slate-200 shadow-sm">
            <div className="text-[11px] font-bold text-slate-400 mb-1">نسبة النجاح</div>
            <div className="text-lg font-black text-[#8B1D3B]">
              {stats.successRate}%
            </div>
            <div className="text-[10px] text-emerald-600 font-bold mt-1 flex items-center gap-1">
              <CheckCircle2 className="w-3 h-3" />
              <span>أعلى دقة تنفيذ</span>
            </div>
          </div>
        </div>

        {/* Operator Breakdown */}
        <div className="bg-white rounded-2xl p-4 border border-slate-200 shadow-sm space-y-3">
          <div className="text-xs font-black text-slate-800 flex items-center gap-2">
            <PieChart className="w-4 h-4 text-[#8B1D3B]" />
            <span>توزيع المبيعات بحسب الشبكات</span>
          </div>

          <div className="space-y-2.5">
            {operatorBreakdown.map((op, idx) => (
              <div key={`report-breakdown-${op.name}-${idx}`} className="space-y-1">
                <div className="flex justify-between text-xs font-bold">
                  <span className="text-slate-800">{op.name}</span>
                  <span className="text-slate-500">
                    {op.percentage}% ({Math.round(op.amount).toLocaleString()} ر.ي)
                  </span>
                </div>
                <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
                  <div
                    className={`h-full ${op.color} rounded-full`}
                    style={{ width: `${op.percentage}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Export / Print */}
        <button
          onClick={() => alert("جاري تصدير التقرير المالي بصيغة PDF...")}
          className="w-full bg-slate-900 hover:bg-slate-800 text-white py-3 rounded-2xl text-xs font-black transition active:scale-[0.99] shadow-md"
        >
          تصدير التقرير المالي (PDF / Excel)
        </button>
      </div>
    </div>
  );
};
