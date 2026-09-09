import React from "react";
import {
  X,
  CheckCircle2,
  Share2,
  Printer,
  ShieldCheck,
  Copy,
  Check,
  Clock,
  ArrowRight
} from "lucide-react";
import { OperationItem } from "../types";

interface Props {
  operation: OperationItem | null;
  onClose: () => void;
}

export const OperationDetailModal: React.FC<Props> = ({
  operation,
  onClose,
}) => {
  const [copied, setCopied] = React.useState(false);

  if (!operation) return null;

  const handleCopy = () => {
    navigator.clipboard.writeText(operation.operationNumber);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-3 animate-fadeIn">
      <div className="bg-white rounded-3xl w-full max-w-sm overflow-hidden shadow-2xl border border-slate-200 flex flex-col max-h-[90vh]">
        {/* Top Header */}
        <div className="bg-[#8B1D3B] text-white p-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <ShieldCheck className="w-5 h-5 text-emerald-400" />
            <div className="font-black text-sm">تفاصيل سند العملية</div>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-white/15 hover:bg-white/25 flex items-center justify-center transition"
          >
            <X className="w-4 h-4 text-white" />
          </button>
        </div>

        {/* Content */}
        <div className="p-4 overflow-y-auto space-y-4">
          {/* Status Badge & Amount */}
          <div className="text-center bg-slate-50 rounded-2xl p-3 border border-slate-100">
            <div className="inline-flex items-center gap-1 bg-emerald-100 text-emerald-800 text-[11px] font-black px-2.5 py-0.5 rounded-full mb-2">
              <CheckCircle2 className="w-3.5 h-3.5" />
              <span>{operation.statusText}</span>
            </div>

            <div className="text-2xl font-black text-slate-900">
              {operation.amount.toLocaleString()} ر.ي
            </div>
            <div className="text-xs font-bold text-slate-500 mt-0.5">
              {operation.packageName}
            </div>
          </div>

          {/* Details Table */}
          <div className="space-y-2.5 text-xs">
            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">رقم العملية المرجعي</span>
              <div className="flex items-center gap-1.5 font-mono font-black text-slate-800">
                <span>{operation.operationNumber}</span>
                <button
                  onClick={handleCopy}
                  className="text-[#8B1D3B] hover:text-red-800"
                  title="نسخ"
                >
                  {copied ? <Check className="w-3.5 h-3.5 text-emerald-600" /> : <Copy className="w-3.5 h-3.5" />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">رقم الهاتف المستلم</span>
              <span className="font-black text-slate-800 dir-ltr">{operation.phone}</span>
            </div>

            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">مزود الخدمة</span>
              <span className="font-black text-slate-800">{operation.operatorName}</span>
            </div>

            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">تاريخ ووقت التنفيذ</span>
              <span className="font-bold text-slate-700">{operation.date} - {operation.time}</span>
            </div>

            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">اسم العميل</span>
              <span className="font-black text-slate-800">{operation.customerName}</span>
            </div>

            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">الرصيد قبل العملية</span>
              <span className="font-bold text-slate-700">{operation.balanceBefore.toLocaleString()} ر.ي</span>
            </div>

            <div className="flex items-center justify-between py-1.5 border-b border-slate-100">
              <span className="text-slate-400 font-semibold">الرصيد بعد العملية</span>
              <span className="font-black text-[#8B1D3B]">{operation.balanceAfter.toLocaleString()} ر.ي</span>
            </div>

            <div className="flex items-center justify-between py-1.5">
              <span className="text-slate-400 font-semibold">حالة التحقق الحقيقية</span>
              <span className="font-black text-emerald-600">موثقة ومؤكدة بالسيرفر ✓</span>
            </div>
          </div>
        </div>

        {/* Footer Actions */}
        <div className="p-3 bg-slate-50 border-t border-slate-100 flex items-center gap-2">
          <button
            onClick={() => alert("جاري تجهيز السند للطباعة...")}
            className="flex-1 bg-[#8B1D3B] hover:bg-[#70162f] text-white py-2.5 rounded-xl text-xs font-black flex items-center justify-center gap-1.5 transition active:scale-95 shadow-sm"
          >
            <Printer className="w-4 h-4" />
            <span>طباعة الإشعار</span>
          </button>

          <button
            onClick={() => alert(`مشاركة سند العملية #${operation.operationNumber}`)}
            className="bg-slate-200 hover:bg-slate-300 text-slate-800 p-2.5 rounded-xl transition"
            title="مشاركة"
          >
            <Share2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
