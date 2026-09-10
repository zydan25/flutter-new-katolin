import React, { useState } from "react";
import {
  ArrowRight,
  Send,
  UserCheck,
  AlertCircle,
  CheckCircle2,
  Lock,
  Wallet,
  RotateCw
} from "lucide-react";
import { submitSubscriberTransfer } from "../services/apiService";

interface Props {
  onBack: () => void;
  walletBalance: number;
  onTransferSuccess: (amount: number, recipientPhone: string, recipientName: string) => void;
}

export const SubscriberTransferScreen: React.FC<Props> = ({
  onBack,
  walletBalance,
  onTransferSuccess,
}) => {
  const [recipientPhone, setRecipientPhone] = useState("");
  const [amount, setAmount] = useState("");
  const [pin, setPin] = useState("");
  const [notes, setNotes] = useState("");
  const [isLookingUp, setIsLookingUp] = useState(false);
  const [foundRecipient, setFoundRecipient] = useState<{ name: string; phone: string } | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successReceipt, setSuccessReceipt] = useState<any>(null);

  const handlePhoneChange = (val: string) => {
    const clean = val.replace(/\D/g, "").slice(0, 9);
    setRecipientPhone(clean);
    setErrorMessage(null);
    if (clean.length === 9) {
      setIsLookingUp(true);
      setTimeout(() => {
        setIsLookingUp(false);
        setFoundRecipient({
          name: clean === "771122334" ? "محمد عبدالله علي الحيمي" : clean === "771642093" ? "زيدان محمد العطاب" : "مشترك شبيك معتمد",
          phone: clean,
        });
      }, 500);
    } else {
      setFoundRecipient(null);
    }
  };

  const handleConfirmTransfer = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);
    const numAmount = Number(amount);
    if (!foundRecipient) {
      setErrorMessage("يرجى إدخال رقم هاتف المشترك المعتمد أولاً (9 أرقام)");
      return;
    }
    if (isNaN(numAmount) || numAmount <= 0) {
      setErrorMessage("يرجى إدخال مبلغ تحويل صحيح");
      return;
    }
    if (numAmount > walletBalance) {
      setErrorMessage(`رصيدك الحالي (${walletBalance.toLocaleString()} ر.ي) لا يكفي لإتمام هذا التحويل`);
      return;
    }
    if (pin.length < 4) {
      setErrorMessage("يرجى إدخال رمز التحويل السري (4 أرقام على الأقل)");
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await submitSubscriberTransfer(foundRecipient.phone, numAmount, pin, notes);
      setIsSubmitting(false);

      if (res.success) {
        onTransferSuccess(numAmount, foundRecipient.phone, res.recipientName || foundRecipient.name);
        setSuccessReceipt({
          transferId: res.transferId || "TR-" + Math.floor(100000 + Math.random() * 900000),
          amount: numAmount,
          recipientName: res.recipientName || foundRecipient.name,
          recipientPhone: foundRecipient.phone,
          serverMessage: res.message,
          date: new Date().toLocaleDateString("ar-YE"),
          time: new Date().toLocaleTimeString("ar-YE", { hour: "2-digit", minute: "2-digit" }),
        });
      } else {
        setErrorMessage(res.message || "فشلت عملية التحويل من الخادم");
      }
    } catch (err: any) {
      setIsSubmitting(false);
      setErrorMessage(err.message || "حدث خطأ أثناء الاتصال بالخادم");
    }
  };

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
          <div className="font-black text-base">تحويل رصيد لمشترك</div>
        </div>

        <div className="w-9 h-9 rounded-full bg-white/15 flex items-center justify-center">
          <Send className="w-5 h-5 text-white" />
        </div>
      </div>

      <div className="p-4 space-y-4">
        {/* Wallet balance banner */}
        <div className="bg-white rounded-2xl p-3.5 border border-slate-200 shadow-sm flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-amber-100 text-amber-800 flex items-center justify-center">
              <Wallet className="w-5 h-5" />
            </div>
            <div>
              <div className="text-[11px] text-slate-400 font-bold">الرصيد المتاح للتحويل</div>
              <div className="text-base font-black text-slate-800">
                {walletBalance.toLocaleString()} ر.ي
              </div>
            </div>
          </div>
          <span className="text-[10px] bg-emerald-100 text-emerald-800 font-black px-2 py-0.5 rounded-md">
            تحويل فوري
          </span>
        </div>

        {successReceipt ? (
          <div className="bg-white rounded-3xl p-5 border border-slate-200 shadow-lg text-center space-y-3 animate-fadeIn">
            <div className="w-14 h-14 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto shadow-inner">
              <CheckCircle2 className="w-8 h-8" />
            </div>
            <div className="text-base font-black text-slate-900">
              تم التحويل بنجاح تام!
            </div>
            <div className="text-2xl font-black text-[#8B1D3B]">
              {successReceipt.amount.toLocaleString()} ر.ي
            </div>

            <div className="bg-slate-50 rounded-2xl p-3 text-xs space-y-1.5 text-right border border-slate-100">
              <div className="flex justify-between">
                <span className="text-slate-400">رقم التحويل</span>
                <span className="font-bold text-slate-800 font-mono">{successReceipt.transferId}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">المستلم</span>
                <span className="font-bold text-slate-800">{successReceipt.recipientName}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">رقم الهاتف</span>
                <span className="font-bold text-slate-800 dir-ltr">{successReceipt.recipientPhone}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">التاريخ والوقت</span>
                <span className="font-bold text-slate-800">{successReceipt.date} - {successReceipt.time}</span>
              </div>
            </div>

            <button
              onClick={() => {
                setSuccessReceipt(null);
                setRecipientPhone("");
                setAmount("");
                setPin("");
                setFoundRecipient(null);
              }}
              className="w-full bg-[#8B1D3B] text-white py-3 rounded-2xl text-xs font-black shadow-md transition"
            >
              إجراء تحويل آخر
            </button>
          </div>
        ) : (
          <form onSubmit={handleConfirmTransfer} className="bg-white rounded-3xl p-4 border border-slate-200 shadow-sm space-y-3.5">
            {/* Phone input */}
            <div>
              <label className="block text-xs font-black text-slate-800 mb-1">
                رقم هاتف المشترك المستلم (9 أرقام)
              </label>
              <div className="relative">
                <input
                  type="tel"
                  maxLength={9}
                  value={recipientPhone}
                  onChange={(e) => handlePhoneChange(e.target.value)}
                  placeholder="مثال: 771122334"
                  className="w-full bg-slate-100 rounded-xl px-3.5 py-2.5 text-xs font-black text-slate-900 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#8B1D3B] text-right"
                  dir="ltr"
                />
                {isLookingUp && (
                  <RotateCw className="w-4 h-4 text-slate-400 animate-spin absolute left-3 top-3" />
                )}
              </div>
            </div>

            {/* Recipient info if found */}
            {foundRecipient && (
              <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-2.5 flex items-center gap-2 text-xs font-bold text-emerald-800 animate-fadeIn">
                <UserCheck className="w-4 h-4 text-emerald-600 shrink-0" />
                <span>المشترك: {foundRecipient.name} ✓</span>
              </div>
            )}

            {/* Amount input */}
            <div>
              <label className="block text-xs font-black text-slate-800 mb-1">
                المبلغ المراد تحويله (ر.ي)
              </label>
              <input
                type="number"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder="ادخل المبلغ..."
                className="w-full bg-slate-100 rounded-xl px-3.5 py-2.5 text-sm font-black text-slate-900 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#8B1D3B]"
              />
            </div>

            {/* Security PIN */}
            <div>
              <label className="block text-xs font-black text-slate-800 mb-1">
                رمز التحويل السري (PIN)
              </label>
              <div className="relative">
                <input
                  type="password"
                  maxLength={6}
                  value={pin}
                  onChange={(e) => setPin(e.target.value)}
                  placeholder="••••"
                  className="w-full bg-slate-100 rounded-xl px-3.5 py-2.5 text-sm font-black text-slate-900 border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#8B1D3B] text-center tracking-widest"
                />
                <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
              </div>
            </div>

            {/* Error Message */}
            {errorMessage && (
              <div className="bg-rose-50 border border-rose-200 rounded-xl p-2.5 flex items-center gap-2 text-xs font-bold text-rose-700 animate-shake">
                <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
                <span>{errorMessage}</span>
              </div>
            )}

            {/* Submit button */}
            <button
              type="submit"
              disabled={isSubmitting || !foundRecipient}
              className="w-full bg-[#8B1D3B] hover:bg-[#70162f] disabled:opacity-50 text-white py-3 rounded-2xl text-xs font-black flex items-center justify-center gap-2 shadow-md transition active:scale-[0.99] mt-2"
            >
              {isSubmitting ? (
                <RotateCw className="w-4 h-4 animate-spin" />
              ) : (
                <Send className="w-4 h-4" />
              )}
              <span>{isSubmitting ? "جاري تنفيذ التحويل..." : "تأكيد إرسال التحويل"}</span>
            </button>
          </form>
        )}
      </div>
    </div>
  );
};
