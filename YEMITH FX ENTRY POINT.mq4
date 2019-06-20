#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#define MAGICMA  2013000

extern int KPeriod = 21;
extern int DPeriod = 12;
extern int Slowing = 3;
extern int method = 0;
extern int price = 0;
extern string для_WPR = "";
extern int ExtWPRPeriod = 14;
extern double ZoneHighPer = 70.0;
extern double ZoneLowPer = 30.0;
extern bool modeone = TRUE;
extern bool PlaySoundBuy = TRUE;
extern bool PlaySoundSell = TRUE;
int gi_136 = 0;
extern string FileSoundBuy = "analyze buy";
extern string FileSoundSell = "analyze sell";
double g_ibuf_156[];
double g_ibuf_160[];
double g_ibuf_164[];
double g_ibuf_168[];
double g_ibuf_172[];
int gi_176 = 0;
int gi_180 = 0;
int g_time_184 = 0;
int gi_188 = 0;
int gi_192 = 0;
int gi_196 = 0;

 double price_field_12;
 double high_20;
 double low_28;
 double ld_40;
 double ld_48;
 double ld_56;
 double ld_64;
 int shift_72;
// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   
   return (0);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
  
  string ls_unused_0;
  
   gi_176 = KPeriod + Slowing;
   gi_180 = gi_176 + DPeriod;
   int li_8 = Bars - 1;
   if(li_8 < 0) return (-1);
   if(li_8 > 0) li_8 --;
   if (Bars <= gi_180) return (0);
   if (li_8 < 1) {
      for (int shift_0 = 1; shift_0 <= gi_176; shift_0++) g_ibuf_156[Bars - shift_0] = 0;
      for (shift_0 = 1; shift_0 <= gi_180; shift_0++) g_ibuf_160[Bars - shift_0] = 0;
   }
   if (li_8 > 0) li_8--;
   int li_36 = Bars - li_8-1;
   for (shift_0 = 0; shift_0 < li_36; shift_0++) {
      g_ibuf_156[shift_0] = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, method, price_field_12, MODE_MAIN, shift_0);
      g_ibuf_160[shift_0] = iStochastic(NULL, 0, 21, DPeriod, Slowing, method, price_field_12, MODE_SIGNAL, shift_0);
   }
   shift_0 = Bars - ExtWPRPeriod - 1;
   if (li_8 > ExtWPRPeriod) shift_0 = Bars - li_8 - 1;
   while (shift_0 >= 0) {
      high_20 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod, shift_0)];
      low_28 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod, shift_0)];
      if (!f0_0(high_20 - low_28, 0.0)) g_ibuf_172[shift_0] = (high_20 - Close[shift_0]) / (-0.01) / (high_20 - low_28) + 100.0;
      shift_0--;
   }
   if (li_8 > 0) li_8--;
   li_36 = Bars - li_8;
   for (shift_0 = li_36 - 1; shift_0 >= 0; shift_0--) {
      ld_40 = g_ibuf_160[shift_0];
      ld_48 = g_ibuf_160[shift_0 + 1];
      ld_56 = g_ibuf_156[shift_0];
      ld_64 = g_ibuf_156[shift_0 + 1];
      if (ld_56 > ld_40 && ld_64 < ld_48 && ld_64 < ZoneLowPer && ld_48 < ZoneLowPer) {
        int res = OrderSend(Symbol(),OP_BUY,1,Ask,3,0,0,"My order",MAGICMA,0,Red);
      } else g_ibuf_164[shift_0] = 0;
      if (ld_56 < ld_40 && ld_64 > ld_48 && ld_64 > ZoneHighPer && ld_48 > ZoneHighPer) {
        res=OrderSend(Symbol(),OP_SELL,1,Bid,3,0,0,"My order",MAGICMA,0,Red);
      } else g_ibuf_168[shift_0] = 0;
   }
   
   return (0);
}

////////////////////////////////////////////////////////////
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void CheckForClose()
  {
   double ma;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1){ return;}
//--- get Moving Average 
  // ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(ld_56 < ld_40 && ld_64 > ld_48 && ld_64 > ZoneHighPer && ld_48 > ZoneHighPer)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(ld_56 > ld_40 && ld_64 < ld_48 && ld_64 < ZoneLowPer && ld_48 < ZoneLowPer)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
     
   }
//---


// 2B740CB84420C7B62E2B7A7086716360
bool f0_0(double ad_0, double ad_8) {
   bool bool_16 = NormalizeDouble(ad_0 - ad_8, 8) == 0.0;
   return (bool_16);
}

void OnTick()
  {
  //if(Bars<100 || IsTradeAllowed()==false){
     // return;
     // }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0){
  start();
  }
  else{
  CheckForClose();
  }
//--- 
   }