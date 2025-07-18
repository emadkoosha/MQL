//+------------------------------------------------------------------+
//|                                                  PinBar_v1.1.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define EXPERT_MAGIC 110
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
CTrade trade;
CPositionInfo posinfo;
double body,downshadow,upshadow,entrybuy, entrysell,tpbuy,tpsell, slbuy, slsell,ask,bid;

input double shadowtobody=1;
input double atrmul=2;

//input double shadowinvert=0.2;
input double shadowpercent=0.5;
//input double bodypercent=0.3;


input double sl_distance=50;
input double lossperposition=20;
input int PeriodRSI=14;
input double R_R=3;

input ENUM_TIMEFRAMES timeframepinbar=PERIOD_M15;

input int EMAfast_period=10;
input int EMAslow_period=20;
input int ATR_per=14;
input int ATRMA_period=14;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   int ATR_handle= iATR(_Symbol,timeframepinbar,ATR_per);
   double atr[];
   ArraySetAsSeries(atr,true);
   CopyBuffer(ATR_handle,0,0,60,atr);

   int MAATR_handle=  iMA(_Symbol,timeframepinbar,ATRMA_period,0,MODE_EMA,ATR_handle);
   double maatr[];
   ArraySetAsSeries(maatr,true);
   CopyBuffer(MAATR_handle,0,0,2,maatr);

   int RSI_handle= iRSI(_Symbol,timeframepinbar,PeriodRSI,PRICE_CLOSE);
   double RSI[];
   ArraySetAsSeries(RSI,true);
   CopyBuffer(RSI_handle,0,0,2,RSI);

   int MA_handle_slow= iMA(_Symbol,timeframepinbar,EMAslow_period,0,MODE_EMA,PRICE_CLOSE);
   double EMAslow[];
   ArraySetAsSeries(EMAslow,true);
   CopyBuffer(MA_handle_slow,0,0,2,EMAslow);

   int MA_handle_fast= iMA(_Symbol,timeframepinbar,EMAfast_period,0,MODE_EMA,PRICE_CLOSE);
   double EMAfast[];
   ArraySetAsSeries(EMAfast,true);
   CopyBuffer(MA_handle_fast,0,0,2,EMAfast);
   bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);



   body=NormalizeDouble(MathAbs(Close(1)-Open(1)),_Digits);
   if(Close(1)>Open(1))
     {

      downshadow=NormalizeDouble(Open(1)-Low(1),_Digits);
      upshadow=NormalizeDouble(High(1)-Close(1),_Digits);
     }
   if(Close(1)<=Open(1))
     {
      downshadow=NormalizeDouble(Close(1)-Low(1),_Digits);
      upshadow=NormalizeDouble(High(1)-Open(1),_Digits);
     }

//   if(PositionsTotal()==0 && countopenbuyorder()==0 &&  downshadow>body*shadowtobody   && EMAfast[1]>EMAslow[1] && Low(1) >EMAfast[1]  && (High(1)-Low(1))>atr[1])
//  if(PositionsTotal()==0 && countopenbuyorder()==0 &&  IsBullishPinBar(1))
   if(IsBullishPinBar(1) && (High(1)-Low(1))> (atrmul*atr[1]) )


     {
      if(Close(1)>Open(1))
        {
         entrybuy=NormalizeDouble(Open(1)-((Open(1)-Low(1))/2),_Digits);
        }
      if(Close(1)<Open(1))
        {
         entrybuy=NormalizeDouble(Close(1)-((Close(1)-Low(1))/2),_Digits);
        }


      slbuy=NormalizeDouble(Low(1)-sl_distance*_Point,_Digits);
      tpbuy=NormalizeDouble(entrybuy+R_R*(entrybuy-slbuy),_Digits);


      if(ask>entrybuy && IsNewBar())
        {
         trade.BuyLimit(positionsizecal(_Symbol,entrybuy,slbuy,lossperposition),entrybuy,_Symbol,slbuy,tpbuy,ORDER_TIME_GTC,0,NULL);
        }
     }

//   if(PositionsTotal()==0 && countopensellorder()==0 && upshadow>body*shadowtobody  && EMAfast[1]<EMAslow[1] && High(1)<EMAfast[1] && (High(1)-Low(1))>atr[1])
//if(PositionsTotal()==0 && countopensellorder()==0 && IsBearishPinBar(1))
   if(IsBearishPinBar(1)  && (High(1)-Low(1))> (atrmul*atr[1]))


     {

      if(Close(1)>Open(1))
        {
         entrysell=NormalizeDouble(High(1)-((High(1)-Close(1))/2),_Digits);
        }
      if(Close(1)<Open(1))
        {
         entrysell=NormalizeDouble(High(1)-((High(1)-Open(1))/2),_Digits);
        }
      slsell=NormalizeDouble(High(1)+sl_distance*_Point,_Digits);
      tpsell=NormalizeDouble(entrysell-R_R*(slsell-entrysell),_Digits);
      if(bid<entrysell && IsNewBar())
        {
         trade.SellLimit(positionsizecal(_Symbol,entrysell,slsell,lossperposition),entrysell,_Symbol,slsell,tpsell,ORDER_TIME_GTC,0,NULL);

        }
     }



   CancelOrdersAfterNCandles(3, timeframepinbar);

  }
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }
//+------

//+------------------------------------------------------------------+
//| Returns the open price of the specified bar                      |
//+------------------------------------------------------------------+
double Open(int index)
  {
   double val=iOpen(_Symbol, timeframepinbar, index);
//--- if the current check state was successful and an error was received
//   if(ExtCheckPassed && val==0)
//      ExtCheckPassed=false;   // switch the status to failed

   return(val);
  }
//+------------------------------------------------------------------+
//| Returns the close price of the specified bar                     |
//+------------------------------------------------------------------+
double Close(int index)
  {
   double val=iClose(_Symbol, timeframepinbar, index);
//--- if the current check state was successful and an error was received
//  if(ExtCheckPassed && val==0)
//     ExtCheckPassed=false;   // switch the status to failed

   return(val);
  }
//+------------------------------------------------------------------+
//| Returns the low price of the specified bar                       |
//+------------------------------------------------------------------+
double Low(int index)
  {
   double val=iLow(_Symbol, timeframepinbar, index);
//--- if the current check state was successful and an error was received
//   if(ExtCheckPassed && val==0)
//      ExtCheckPassed=false;   // switch the status to failed

   return(val);
  }
//+------------------------------------------------------------------+
//| Returns the high price of the specified bar                      |
//+------------------------------------------------------------------+
double High(int index)
  {
   double val=iHigh(_Symbol, timeframepinbar, index);
//--- if the current check state was successful and an error was received
//   if(ExtCheckPassed && val==0)
//      ExtCheckPassed=false;   // switch the status to failed

   return(val);
  }
//+------------------------------------------------------------------+
double positionsizecal(string symbol,double entry, double sl, double lp)
  {
   double ret=MathAbs((entry-sl)/entry);
   if(symbol=="EURUSD" || symbol=="GBPUSD" || symbol=="AUDUSD" || symbol=="NZDUSD")
     {
      double lot=(lp/ret)/entry;
      double lotsize= lot/100000;
      return NormalizeDouble(lotsize,2);
     }
   else
      if(symbol=="USDJPY" || symbol=="USDCHF" || symbol=="USDCAD")
        {
         double lot=(lp/ret);
         double lotsize= lot/100000;
         return NormalizeDouble(lotsize,2);
        }
      else
        {
         string sy_final;
         string sy=StringSubstr(symbol,3,-1);
         if(sy=="AUD" || sy=="NZD" || sy=="EUR" || sy=="GBP")
           {
            sy_final=sy+"USD";
           }
         else
           {
            sy_final="USD"+sy;
            double lpminor=lp*SymbolInfoDouble(sy_final,SYMBOL_ASK);
            double lot=(lpminor/ret)/entry;
            double lotsize= lot/100000;
            return NormalizeDouble(lotsize,2);
           }

        }
   return -100;
  }
//+------------------------------------------------------------------+
void closeorder()

  {
   int total=OrdersTotal();
   if(total>0)
     {
      for(int j=total-1; j>=0; j--)
        {
         ulong ticket_o=OrderGetTicket(j);

         trade.OrderDelete(ticket_o);

        }


     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countopenbuyorder()
  {

   int count=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      ulong ticket=OrderGetTicket(i);

      if(OrderSelect(ticket))
        {
         int type = (int)OrderGetInteger(ORDER_TYPE);
         if(type== ORDER_TYPE_BUY || type== ORDER_TYPE_BUY_LIMIT || type== ORDER_TYPE_BUY_STOP)
            count++;
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
int countopensellorder()
  {

   int count=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      ulong ticket=OrderGetTicket(i);

      if(OrderSelect(ticket))
        {
         int type = (int)OrderGetInteger(ORDER_TYPE);
         if(type== ORDER_TYPE_SELL || type== ORDER_TYPE_SELL_LIMIT || type== ORDER_TYPE_SELL_STOP)
            count++;
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelOrdersAfterNCandles(int nCandles, ENUM_TIMEFRAMES tf)
  {
   datetime currentTime = iTime(_Symbol, tf, 0); // زمان کندل فعلی

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket))
         continue;

      int type = (int)OrderGetInteger(ORDER_TYPE);
      if(type != ORDER_TYPE_BUY_LIMIT && type != ORDER_TYPE_SELL_LIMIT)
         continue;

      datetime orderTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      int shift = iBarShift(_Symbol, tf, orderTime, false);

      if(shift == -1)
         continue;

      if(shift >= nCandles)
        {

         trade.OrderDelete(ticket);
         Print("سفارش #", ticket, " پس از ", shift, " کندل کنسل شد.");
        }
     }
  }
//+------------------------------------------------------------------+
int countopenbuypositions()
  {

   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);

      if(PositionSelect((string)ticket))
        {
         int type = (int)PositionGetInteger(POSITION_TYPE);
         if(type== POSITION_TYPE_BUY)
            count++;
        }
     }
   return count;
  }
//+------------------------------------------------------------------+
int countopensellpositions()
  {

   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);

      if(PositionSelect((string) ticket))
        {
         int type = (int) PositionGetInteger(POSITION_TYPE);
         if(type== POSITION_TYPE_SELL)
            count++;
        }
     }
   return count;
  }

//+------------------------------------------------------------------+
bool IsBullishPinBar(int index)
  {
   double open  = iOpen(_Symbol, timeframepinbar, index);
   double close = iClose(_Symbol, timeframepinbar, index);
   double high  = iHigh(_Symbol, timeframepinbar, index);
   double low   = iLow(_Symbol, timeframepinbar, index);

   double bodycal        = MathAbs(close - open);
   double totalLength = high - low;
   double lowerShadow = MathMin(open, close) - low;
   double upperShadow = high - MathMax(open, close);
   double bodyPos     = upperShadow / totalLength;


   if(body <= 0)
      return false;

   if(lowerShadow / totalLength < shadowpercent)
      return false;
//
//   if(bodyPos > shadowinvert)
//      return false;
//
//   if(bodycal/totalLength <bodypercent)
//      return false;
//
//   if(totalLength < 20 * _Point)
//      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearishPinBar(int index)
  {
   double open  = iOpen(_Symbol, timeframepinbar, index);
   double close = iClose(_Symbol, timeframepinbar, index);
   double high  = iHigh(_Symbol, timeframepinbar, index);
   double low   = iLow(_Symbol, timeframepinbar, index);

   double bodycal        = MathAbs(close - open);
   double totalLength = high - low;
   double upperShadow = high - MathMax(open, close);
   double lowerShadow = MathMin(open, close) - low;
   double bodyPos     = lowerShadow / totalLength;

   if(body <= 0)
      return false;

   if(upperShadow / totalLength < shadowpercent)
      return false;

//if(bodyPos > shadowinvert)
//   return false;
//
//      if(bodycal/totalLength < bodypercent)
//      return false;

   if(totalLength < 20 * _Point)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
