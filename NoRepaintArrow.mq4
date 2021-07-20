//+------------------------------------------------------------------+
//|                                                TestMACDCross.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double InpOrderSize = 0.01;//Order size
extern string InpTradeComment = "TiDoEA";//Your Trade Comment
extern int    InpMagicNumber = 123456789;//Your Magic Number
extern string InpIndicatorName = "NO REPAINT ARROWS";//Indicator MQL4\Indicators\NO REPAINT ARROWS.ex4
extern string MyChannel="https://www.youtube.com/channel/UC-ynazgYCheLU0t0pQsh0cw";//My Channel
extern string MyEmail="anhpnh@gmail.com";//My Email
extern string BuyCoffee="https://www.paypal.com/paypalme/anhpnh";//Buy me a coffee



double TakeProfit; //After conversion from points
double StopLoss;
color ColorTrade;

//Indentify the buffer numbers;
const string IndicatorName = InpIndicatorName;
const int BufferBuy = 2;
const int BufferSell = 3;

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
   //Only run once per bar
   if(!NewBar()) return;
   
   //Perform calculations and analysis
   static double lastBuy = 0;
   static double lastSell = 0;
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
   
   bool buyCondition = (lastBuy!=currentBuy) && (lastBuy!= 0);
   bool sellCondition = (lastSell!=currentSell) && (lastSell != 0);
      
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
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber && OrderType()==ordertype){
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0);
         }
      }
   }
}

