include "MarketInterface.iol"
include "console.iol"
include "time.iol"
include "math.iol"

outputPort MarketService {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: MarketInterface
}

//Type custom per la registrazione da tastiera
type RegisterForInputRequest:void { 
    .enableSessionListener?:bool
}
//Metodo per la stampa degli Stock appena registrati
define stampaStockInPlayer {
   for ( i=0, i<#global.StockStructure.Value, i++ ) {
            println@Console( "STOCK:\n|" + global.StockStructure.Value[i].name + 
                            " |\n|Disponibilità: " + global.StockStructure.Value[i].available + 
                            " |\n|Prezzo: " + global.StockStructure.Value[i].price +
                            " |\n°°°°°°°°°°°°°°°°°°°°°°°°°\n"  )()
    }
}
//Metodo per stampare gli stock dopo ogni Acquisto/Vendita
define stampaStockPosseduti
{
    for ( j=0,j<#global.PlayersTot.Player[indexPlayer].stock , j++ ) {
      println@Console( "||" + global.PlayersTot.Player[indexPlayer].stock[j].name +
       "||Quantità " + global.PlayersTot.Player[indexPlayer].stock[j].possessed+
       "|| Prezzo " + global.PlayersTot.Player[indexPlayer].stock[j].price +"||")()
    }
}

main{
    //Registro il nome del nuovo Player da tastiera
    registerForInput@Console()();
    print@Console( "Inserisci Nome Player: ")();
    in( input);
    nomePlayer = string(input);
    println@Console( "\n" )();

    //Invio al Market la richiesta di registrazione, e di stampa
    //del proprio account
    creaPlayer@MarketService(nomePlayer)(global.PlayersTot);
    stampaPlayer@MarketService(global.PlayersTot)(respost);
    println@Console( respost )();
    richiediIndex@MarketService()(indexPlayer);
    sleep@Time(500)();

    //Richiedo al Market se gli Stock si sono registrati,
    //in caso contrario attendo all'interno del While
    richiediStockVisibili@MarketService()(stockDisponibili);
    while( stockDisponibili!= true) {
      println@Console( "ATTENDERE GLI STOCK...\n°°°°°°°°°°°°°°°" )();
      sleep@Time(4000)();
      richiediStockVisibili@MarketService()(stockDisponibili)
    };

    //Non appena gli Stock si sono registrati richiedo al 
    //Market gli Stock e stampo la StockStructure
    richiediStock@MarketService()(global.StockStructure);
    println@Console( "STOCK DISPONIBILI\n°°°°°°°°°°°°°°°\n" )();
    sleep@Time(500)();
    stampaStockInPlayer;

    //inizializzo le variabili sottostanti per controllare il primo acquisto
    //e le pongo a true tutte le volte che vi è una vendita e lo stock posseduto
    //appena venduto scende a zero, così che alla successiva iterazione lo acquisterà
    granoIniziale = true;
    oroIniziale =true;
    petrolioIniziale = true;
    
    //While per ACQUISTO/VENDITA di Stock
    while(stockDisponibili !=false){
        //Acquisto oro se il Player non lo possiede
        if ((oroIniziale == true) && (global.PlayersTot.Player[indexPlayer].stock[0].possessed==0)){
                oldCash = global.PlayersTot.Player[indexPlayer].cash;
                acquistaOro@MarketService(indexPlayer)(global.PlayersTot);
                newCash = global.PlayersTot.Player[indexPlayer].cash;
                //Controllo se l'acquisto è stato effettuato o meno attraverso la diff di cash
                if( oldCash == newCash ) {
                    println@Console( "ORO NON ACQUISTATO || Cash: " + oldCash )();
                    stampaStockPosseduti
                }else {
                    sleep@Time(100)();
                    println@Console( "ORO ← || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                    stampaStockPosseduti;
                    println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                    oroIniziale = false
                }
                    
        };

        sleep@Time(1000)();
        //Acquisto grano se il Player non lo possiede
        if ((global.PlayersTot.Player[indexPlayer].stock[1].possessed==0)&&(granoIniziale ==true )){
                oldCash = oldCash = global.PlayersTot.Player[indexPlayer].cash;
                acquistaGrano@MarketService(indexPlayer)(global.PlayersTot);
                newCash = global.PlayersTot.Player[indexPlayer].cash;
                //Controllo se l'acquisto è stato effettuato o meno attraiverso la diff di cash
                if( oldCash == newCash ) {
                    println@Console( "GRANO NON ACQUISTATO || Cash: " + oldCash )();
                    stampaStockPosseduti
                }else {
                    sleep@Time(100)();
                    println@Console( "GRANO ← || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                    stampaStockPosseduti;
                    println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                    granoIniziale = false
                }
        };

        sleep@Time(1000)();
        //Acquisto petrolio se il Player non lo possiede
        if((petrolioIniziale == true) && (global.PlayersTot.Player[indexPlayer].stock[2].possessed==0)){
                oldCash = oldCash = global.PlayersTot.Player[indexPlayer].cash;
                acquistaPetrolio@MarketService(indexPlayer)(global.PlayersTot);
                newCash = global.PlayersTot.Player[indexPlayer].cash;
                if( oldCash == newCash ) {
                    println@Console( "PETROLIO NON ACQUISTATO || Cash: " + oldCash )();
                    stampaStockPosseduti
                }else {
                    sleep@Time(100)();
                    println@Console( "PETROLIO ← || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                    stampaStockPosseduti;
                    println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                    petrolioIniziale = false
                }
        };
        
        //Calcolo un val Random da assegnare allo Sleep
        min = 500;
        max = 3000;
        random@Math()(tempoRandom);
        tempoRandom = int(tempoRandom*(max-min+1)+min);
        sleep@Time(tempoRandom)();

        //Richiedo i nuovi prezzi al Market
        richiediPrezzoOro@MarketService()(prezzoOro);
        richiediPrezzoGrano@MarketService()(prezzoGrano);
        richiediPrezzoPetrolio@MarketService()(prezzoPetrolio);

        //Controllo se non possiedo uno dei tre Stock, in tal caso eseguo
        //il rapporto tra i nuovi prezzi e quelli ai quali ho acquistato gli Stock
        //per valutare la percentuale di guadagno/perdita su ogni acquisto
        if( global.PlayersTot.Player[indexPlayer].stock[0].price == 0 ) {
            differenzaOro = 0;
            differenzaGrano=(prezzoGrano-global.PlayersTot.Player[indexPlayer].stock[1].price)/(global.PlayersTot.Player[indexPlayer].stock[1].price);
            differenzaPetrolio=prezzoPetrolio-global.PlayersTot.Player[indexPlayer].stock[2].price/(global.PlayersTot.Player[indexPlayer].stock[2].price)
        }else if( global.PlayersTot.Player[indexPlayer].stock[1].price == 0 ) {
            differenzaGrano=0;
            differenzaOro=(prezzoOro - global.PlayersTot.Player[indexPlayer].stock[0].price)/(global.PlayersTot.Player[indexPlayer].stock[0].price);
            differenzaPetrolio=prezzoPetrolio-global.PlayersTot.Player[indexPlayer].stock[2].price/(global.PlayersTot.Player[indexPlayer].stock[2].price)
        }else if( global.PlayersTot.Player[indexPlayer].stock[2].price == 0 ) {
            differenzaPetrolio = 0;
            differenzaOro=(prezzoOro - global.PlayersTot.Player[indexPlayer].stock[0].price)/(global.PlayersTot.Player[indexPlayer].stock[0].price);
            differenzaGrano=(prezzoGrano-global.PlayersTot.Player[indexPlayer].stock[1].price)/(global.PlayersTot.Player[indexPlayer].stock[1].price)
        }else{
            differenzaOro=(prezzoOro - global.PlayersTot.Player[indexPlayer].stock[0].price)/(global.PlayersTot.Player[indexPlayer].stock[0].price);
            differenzaGrano=(prezzoGrano-global.PlayersTot.Player[indexPlayer].stock[1].price)/(global.PlayersTot.Player[indexPlayer].stock[1].price);
            differenzaPetrolio=prezzoPetrolio-global.PlayersTot.Player[indexPlayer].stock[2].price/(global.PlayersTot.Player[indexPlayer].stock[2].price)
        };

        //Setto il coeff di guadagno al 20%
        coeffGuadagno= double("0.20");

        //Se esiste un margine di guadagno sul coeffGuadagno vendo lo Stock che mi da il maggior guadagno
        if( (differenzaOro>coeffGuadagno)||(differenzaGrano>coeffGuadagno)||(differenzaPetrolio>coeffGuadagno)) {
            if( (differenzaOro>differenzaGrano)&&(differenzaOro>differenzaPetrolio)&&(global.PlayersTot.Player[indexPlayer].stock[0].possessed >0) ) {
                vendiOro@MarketService(indexPlayer)(global.PlayersTot);
                sleep@Time(100)();
                println@Console( "ORO ➔ || Cash: "+global.PlayersTot.Player[global.indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                if( global.PlayersTot.Player[indexPlayer].stock[0].possessed == 0 ) {
                    //Setto oroInziale a true per permettere il nuovo acquisto alla prossima iterazione
                    oroIniziale = true
                }
                    
            }else if ( (differenzaGrano>differenzaOro)&&(differenzaGrano>differenzaPetrolio)&&(global.PlayersTot.Player[indexPlayer].stock[1].possessed >0) ) {
                vendiGrano@MarketService(indexPlayer)(global.PlayersTot);
                sleep@Time(100)();
                println@Console( "GRANO ➔ || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                if( global.PlayersTot.Player[indexPlayer].stock[1].possessed == 0 ) {
                    //Setto granoInziale a true per permettere il nuovo acquisto alla prossima iterazione
                    granoIniziale = true
                }
            }else if( (differenzaPetrolio>differenzaOro)&&(differenzaPetrolio>differenzaGrano)&&( global.PlayersTot.Player[indexPlayer].stock[2].possessed >0) ) {
                vendiPetrolio@MarketService(indexPlayer)(global.PlayersTot);
                sleep@Time(100)();
                println@Console( "PETROLIO ➔ || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                if( global.PlayersTot.Player[indexPlayer].stock[2].possessed == 0 ) {
                    //Setto petrolioInziale a true per permettere il nuovo acquisto alla prossima iterazione
                    petrolioIniziale = true
                }
            }    
        };
        
        //Calcolo un val Random da assegnare allo Sleep
        min = 500;
        max = 3000;
        random@Math()(tempoRandom2);
        tempoRandom2 = int(tempoRandom2*(max-min+1)+min);
        sleep@Time(tempoRandom)();

        //Calcolo il val Random per scegliere qualo Stock acquistare
        min = 0;
        max = 2;
        random@Math()(indiceStock);
        indiceStock = int(indiceStock*(max-min+1)+min);

        //Acquisto oro nel caso in cui l'indice ottenuto sia zero
        if( indiceStock == 0 ) {                
            oldCash = global.PlayersTot.Player[indexPlayer].cash;
            acquistaOro@MarketService(indexPlayer)(global.PlayersTot);
            newCash = global.PlayersTot.Player[indexPlayer].cash;
            if( oldCash == newCash ) {
                println@Console( "ORO NON ACQUISTATO || Cash: " + oldCash )();
                stampaStockPosseduti
            }else {
                sleep@Time(100)();
                println@Console( "ORO ← || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                oroIniziale = false
            }
        //Acquisto grano nel caso in cui l'indice ottenuto sia uno
        }else if(indiceStock ==1){
            oldCash = oldCash = global.PlayersTot.Player[indexPlayer].cash;
            acquistaGrano@MarketService(indexPlayer)(global.PlayersTot);
            newCash = global.PlayersTot.Player[indexPlayer].cash;
            if( oldCash == newCash ) {
                println@Console( "GRANO NON ACQUISTATO || Cash: " + oldCash )();
                stampaStockPosseduti
            }else {
                sleep@Time(100)();
                println@Console( "GRANO ← || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                granoIniziale = false
            }
         //Acquisto petrolio nel caso in cui l'indice ottenuto sia due
        }else {
            oldCash = oldCash = global.PlayersTot.Player[indexPlayer].cash;
            acquistaPetrolio@MarketService(indexPlayer)(global.PlayersTot);
            newCash = global.PlayersTot.Player[indexPlayer].cash;
            if( oldCash == newCash ) {
                println@Console( "PETROLIO NON ACQUISTATO || Cash: " + oldCash )();
                stampaStockPosseduti
            }else {
                sleep@Time(100)();
                println@Console( "PETROLIO ← || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                petrolioIniziale = false
            }
        };

        sleep@Time(1000)();

        //Eseguo il controllo sul cash disponibile del Player, nel caso in cui sia inferiore
        // 10€ eseguo la vendita di ogni Stock posseduto 
        if( global.PlayersTot.Player[global.indexPlayer].cash < 10 ) {
          if( global.PlayersTot.Player[indexPlayer].stock[0].possessed >0 ) {
                vendiOro@MarketService(indexPlayer)(global.PlayersTot);
                sleep@Time(100)();
                println@Console( "Oro ➔ || Cash: "+global.PlayersTot.Player[global.indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                if( global.PlayersTot.Player[indexPlayer].stock[0].possessed == 0 ) {
                    oroIniziale = true
                }
            };

          if( global.PlayersTot.Player[indexPlayer].stock[1].possessed >0  ) {
                vendiGrano@MarketService(indexPlayer)(global.PlayersTot);
                sleep@Time(100)();
                println@Console( "Grano ➔ || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                if( global.PlayersTot.Player[indexPlayer].stock[1].possessed == 0 ) {
                    granoIniziale = true
                }
            };

          if( global.PlayersTot.Player[indexPlayer].stock[2].possessed >0 ) {
                vendiPetrolio@MarketService(indexPlayer)(global.PlayersTot);
                sleep@Time(100)();
                println@Console( "Petrolio ➔ || Cash: "+global.PlayersTot.Player[indexPlayer].cash+"||")();
                stampaStockPosseduti;
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
                if( global.PlayersTot.Player[indexPlayer].stock[2].possessed == 0 ) {
                    petrolioIniziale = true
                }
            }
        }   
    }
}

  

