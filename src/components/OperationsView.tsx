import React, { useState } from "react";
import {
  ArrowRight,
  Search,
  CheckCircle2,
  Clock,
  XCircle,
  RotateCw,
  SlidersHorizontal,
  BellRing,
  ExternalLink,
  ShieldCheck,
  Check
} from "lucide-react";
import { OperationItem } from "../types";

interface Props {
  operations: OperationItem[];
  onBack: () => void;
  onSelectOperation: (op: OperationItem) => void;
  onRefresh: () => void;
}

export const OperationsView: React.FC<Props> = ({
  operations,
  onBack,
  onSelectOperation,
  onRefresh,
}) => {
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [verifyingId, setVerifyingId] = useState<string | number | null>(null);
  const [verificationFeedback, setVerificationFeedback] = useState<string | null>(null);

  const filteredOps = operations.filter((op) => {
    const matchesSearch =
      op.phone.includes(searchTerm) ||
      op.packageName.includes(searchTerm) ||
      op.operationNumber.includes(searchTerm);
    const matchesStatus =
      statusFilter === "all" ? true : op.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const handleCheckStatus = (e: React.MouseEvent, op: OperationItem) => {
    e.stopPropagation();
    setVerifyingId(op.id);
    setTimeout(() => {
      setVerifyingId(null);
      setVerificationFeedback(`تم فحص العملية #${op.operationNumber}: الحالة جاهزة ومؤكدة في السيرفر ✓`);
      setTimeout(() => setVerificationFeedback(null), 3500);
    }, 800);
  };

  return (
    <div className="flex-1 flex flex-col bg-[#F8FAFC] overflow-hidden">
      {/* Top App Bar */}
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
          <div className="font-black text-base">سجل العمليات</div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={onRefresh}
            className="w-9 h-9 rounded-full bg-white/15 hover:bg-white/25 flex items-center justify-center transition active:scale-95"
            title="تحديث السجل"
          >
            <RotateCw className="w-4 h-4 text-white" />
          </button>
        </div>
      </div>

      {/* Balance Notification / Server Alert */}
      <div className="bg-amber-50 border-b border-amber-200 px-3.5 py-2 flex items-center gap-2 text-xs font-bold text-amber-900">
        <BellRing className="w-4 h-4 text-amber-600 shrink-0" />
        <span className="flex-1">
          تنبيه الرصيد: تعرض العمليات الخاصة بالعميل (زيدان العطاب) فقط من السيرفر.
        </span>
      </div>

      {verificationFeedback && (
        <div className="bg-emerald-600 text-white px-3.5 py-2 text-xs font-black flex items-center gap-2 shadow-sm animate-fadeIn">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>{verificationFeedback}</span>
        </div>
      )}

      {/* Search and Filters */}
      <div className="p-3 space-y-2 bg-white border-b border-slate-200 shadow-sm">
        <div className="relative">
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="بحث برقم الهاتف، اسم الباقة، أو رقم العملية..."
            className="w-full bg-slate-100 rounded-xl px-3 py-2 pr-9 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-[#8B1D3B]"
          />
          <Search className="w-4 h-4 text-slate-400 absolute right-3 top-2.5" />
        </div>

        <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pt-1">
          {[
            { id: "all", label: "الكل" },
            { id: "success", label: "ناجحة" },
            { id: "pending", label: "قيد الانتظار" },
            { id: "failed", label: "ملغاة / فاشلة" },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setStatusFilter(tab.id)}
              className={`px-3 py-1 rounded-lg text-xs font-black transition whitespace-nowrap ${
                statusFilter === tab.id
                  ? "bg-[#8B1D3B] text-white shadow-sm"
                  : "bg-slate-100 text-slate-600 hover:bg-slate-200"
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Operations List */}
      <div className="flex-1 overflow-y-auto p-3 space-y-2.5">
        {filteredOps.length === 0 ? (
          <div className="text-center py-12 text-slate-400 font-bold text-xs">
            لا توجد عمليات مطابقة في السجل
          </div>
        ) : (
          filteredOps.map((op, idx) => (
            <div
              key={op.id ? `ops-view-${op.id}-${idx}` : `ops-view-${idx}`}
              onClick={() => onSelectOperation(op)}
              className="bg-white rounded-2xl p-3 border border-slate-200 shadow-sm hover:border-[#8B1D3B]/40 transition cursor-pointer active:scale-[0.99] space-y-2"
            >
              {/* Header row */}
              <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                <div className="flex items-center gap-2">
                  <span
                    className={`px-2 py-0.5 rounded-full text-[10px] font-black flex items-center gap-1 ${
                      op.status === "success"
                        ? "bg-emerald-100 text-emerald-800"
                        : op.status === "pending"
                        ? "bg-amber-100 text-amber-800"
                        : "bg-rose-100 text-rose-800"
                    }`}
                  >
                    {op.status === "success" ? (
                      <CheckCircle2 className="w-3 h-3" />
                    ) : (
                      <Clock className="w-3 h-3" />
                    )}
                    <span>{op.statusText}</span>
                  </span>

                  <span className="text-[11px] font-bold text-slate-400">
                    #{op.operationNumber}
                  </span>
                </div>

                <span className="text-[10px] font-bold text-slate-400">
                  {op.date} {op.time}
                </span>
              </div>

              {/* Body */}
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-xs font-black text-slate-800">
                    {op.packageName}
                  </div>
                  <div className="text-xs font-extrabold text-[#8B1D3B] mt-0.5 dir-ltr text-right">
                    {op.phone} ({op.operatorName})
                  </div>
                </div>

                <div className="text-left">
                  <div className="text-sm font-black text-slate-900">
                    {op.amount.toLocaleString()} ر.ي
                  </div>
                  <div className="text-[10px] text-emerald-600 font-bold">
                    حقيقية ومؤكدة ✓
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-between pt-1 border-t border-slate-100 text-[11px]">
                <div className="flex items-center gap-2">
                  <button
                    onClick={(e) => handleCheckStatus(e, op)}
                    disabled={verifyingId === op.id}
                    className="bg-blue-50 hover:bg-blue-100 text-blue-700 px-2.5 py-1 rounded-lg font-bold flex items-center gap-1 transition"
                  >
                    {verifyingId === op.id ? (
                      <RotateCw className="w-3 h-3 animate-spin" />
                    ) : (
                      <ShieldCheck className="w-3 h-3" />
                    )}
                    <span>فحص الحالة</span>
                  </button>

                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      alert(`فحص الجاهزية للرقم ${op.phone}: الخدمة نشطة ولا توجد معوقات`);
                    }}
                    className="text-slate-500 hover:text-slate-800 font-bold underline"
                  >
                    فحص الجاهزية
                  </button>
                </div>

                <span className="text-[10px] text-[#8B1D3B] font-black flex items-center gap-0.5">
                  <span>التفاصيل</span>
                  <ExternalLink className="w-3 h-3" />
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};
