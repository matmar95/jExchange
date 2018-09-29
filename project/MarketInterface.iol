//Type custom per generare la struttura
//dei tre Stock
type StockType: void {
	.Value[0,*]:void
	{
		.name: string
		.price: double
		.available: double
	}
}

//Type custom per generare la struttura
//in cui memorizzare i Player
type PlayersTot:void {
    .Player[0,*]:void{
      .name:string
      .cash: double
      .stock[0,*]:StockPlayer
    }
}

//Type custom utilizzato per la creazione
//di ogni stock che si registrerà su Market
type Stocks: void {
  	.name: string
		.price: double
		.available: double 
}

//Type custom di ogni stock posseduto dal Player
type StockPlayer: void {
      .name:string
      .price:double
      .possessed:int
}



interface MarketInterface {
  RequestResponse: creaPlayer(string)(PlayersTot),
  				         stampaPlayer(PlayersTot)(string),
                   richiediIndex(void)(int),
                   
                   oroTrue(bool)(void),
                   granoTrue(bool)(void),
                   petrolioTrue(bool)(void),

                   creaStock(Stocks)(StockType),
                   richiediStockVisibili(void)(bool),                 
  				         richiediStock(void)(StockType),

  				         richiediOro(int)(bool),
  				         acquistaOro(int)(PlayersTot),
                   vendiOro(int)(PlayersTot),

                   richiediGrano(int)(bool),
                   acquistaGrano(int)(PlayersTot),
                   vendiGrano(int)(PlayersTot),

                   richiediPetrolio(int)(bool),
                   acquistaPetrolio(int)(PlayersTot),
                   vendiPetrolio(int)(PlayersTot),

                   inviaIncrementoOro(double)(void),
                   inviaDisponibilitaOro(double)(void),

                   inviaIncrementoGrano(double)(void),
                   inviaDecrementoGrano(double)(void),
                   inviaDisponibilitaGrano(double)(void),

                   inviaIncrementoPetrolio(double)(void),
                   inviaDecrementoPetrolio(double)(void),
                   inviaDisponibilitaPetrolio(double)(void),

                   richiediPrezzoOro(void)(double),
                   richiediPrezzoGrano(void)(double),
                   richiediPrezzoPetrolio(void)(double),

}
