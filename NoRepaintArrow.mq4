//+------------------------------------------------------------------+
//|                                                TestMACDCross.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

extern double InpOrderSize = 0.01;//Order size
extern string InpTradeComment = "TiDoEA";//Your Trade Comment
extern int    InpMagicNumber = 123456789;//Your Magic Number
extern string InpIndicatorName = "NO REPAINT ARROWS";//Indicator MQL4\Indicators\NO REPAINT ARROWS.ex4
extern bool InpFilterTime=false;//Fiter trading time
extern int    Start_Time=8;//Start Time Hour
extern int    Finish_Time=20;//End Time Hour
extern string MyChannel="https://www.youtube.com/channel/UC-ynazgYCheLU0t0pQsh0cw";//My Channel
extern string MyEmail="anhpnh@gmail.com";//My Email
extern string BuyCoffee="https://www.paypal.com/paypalme/anhpnh";//Buy me a coffee



double TakeProfit; //After conversion from points
double StopLoss;
double maValue, close, rsiValue;
color ColorTrade;

//Indentify the buffer numbers;
const string IndicatorName = InpIndicatorName;
const int BufferBuy = 4;
const int BufferSell = 5;
int Current_Time;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
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
   if (!AllowTradesByTime()) {
      CloseAll(ORDER_TYPE_BUY);
      CloseAll(ORDER_TYPE_SELL);
      Comment("Not Trade, Closed All Order");
      return;
   }
   
   //Start time trade
   if(AllowTradesByTime()){
      Comment("Allow Trade, Cheking Bars");
      //Only run once per bar
      if(!NewBar()) return;
      
      //Perform calculations and analysis
      static double lastBuy = 0;
      static double lastSell = 0;
      
      maValue = iMA(Symbol(), PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE, 1);
      rsiValue = iRSI(Symbol(),PERIOD_CURRENT, 14, PRICE_CLOSE, 1);
      //Comment(rsiValue);
      close = Close[1];
      
      double currentBuy = iCustom(
         Symbol(),
         Period(),
         IndicatorName,
         BufferBuy,
         1
      );
      double currentSell = iCustom(
         Symbol(),
         Period(),
         IndicatorName,
         BufferSell,
         1
      );
      
      //Execute trade
      
      bool buyCondition = (lastBuy!=currentBuy) && (lastBuy == -1) &&(close > maValue) && (50 < rsiValue < 65);
      bool sellCondition = (lastSell!=currentSell) && (lastSell == -1) &&(close < maValue) && ( 35 < rsiValue < 50);
      
      bool closeSellArrow = (lastBuy!=currentBuy) && (lastBuy == -1);
      bool closeBuyArrow = (lastSell!=currentSell) && (lastSell == -1);
      
      bool closeBuy = (rsiValue >= 65);
      bool closeSell = (rsiValue <= 35);
      
      if(closeBuyArrow){
         CloseAll(ORDER_TYPE_BUY);
      }
      
      if(closeSellArrow){
         CloseAll(ORDER_TYPE_SELL);
      }
      
      if(closeBuy){
         CloseAll(ORDER_TYPE_BUY);
      }
      
      if(closeSell){
         CloseAll(ORDER_TYPE_SELL);
      }
         
      if(buyCondition){
         CloseAll(ORDER_TYPE_SELL);
         ColorTrade = clrBlue;
         if(OrdersTotal()==0){
            OrderOpen(ORDER_TYPE_BUY, StopLoss, TakeProfit);
         }
         
      } else
      
      if(sellCondition){
         CloseAll(ORDER_TYPE_BUY);
         ColorTrade = clrRed;
         if(OrdersTotal()==0){
            OrderOpen(ORDER_TYPE_SELL, StopLoss, TakeProfit);
         }
         
      }
   
      
      //Save any information for next time
      lastBuy = currentBuy;
      lastSell = currentSell;
      
      return;
   }
   

  }
//+------------------------------------------------------------------+


bool NewBar(){
   static datetime prevTime = 0;
   datetime currentTime = iTime(Symbol(), Period(), 0);
   if(currentTime!=prevTime){
      prevTime = currentTime;
      return(true);
   }
   return(false);
}


bool OrderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit){
   int ticket;
   double openPrice;
   double stopLossPrice;
   double takeProfitPrice;
   
   if(orderType==ORDER_TYPE_BUY) {
      openPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      stopLossPrice = openPrice - stopLoss;
      takeProfitPrice = openPrice + takeProfit;
   } else
   if(orderType==ORDER_TYPE_SELL){
      openPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      stopLossPrice = openPrice + stopLoss;
      takeProfitPrice = openPrice - takeProfit;
   } else {
      return(false);
   }
   
   ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber, 0, ColorTrade);
   return(ticket > 0);
}

void CloseAll(ENUM_ORDER_TYPE ordertype){
   int cnt = OrdersTotal();
   for(int i=cnt-1; i>=0; i--){
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber && OrderType()==ordertype && OrderComment()==InpTradeComment){
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
   }
}

bool AllowTradesByTime()
{
   
   if(InpFilterTime==true){
      Current_Time = TimeHour(TimeCurrent());
   if (Start_Time == 0) Start_Time = 24; if (Finish_Time == 0) Finish_Time = 24; if (Current_Time == 0) Current_Time = 24;
      
   if ( Start_Time < Finish_Time )
      if ( (Current_Time < Start_Time) || (Current_Time >= Finish_Time) ) return(false);
      
   if ( Start_Time > Finish_Time )
      if ( (Current_Time < Start_Time) && (Current_Time >= Finish_Time) ) return(false);
      
   return(true);
   }
    
   return(true);
}
