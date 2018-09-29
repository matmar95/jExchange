include "MarketInterface.iol"
include "StockInterface.iol"
include "console.iol"
include "time.iol"
include "semaphore_utils.iol"

outputPort Stock {
	Location: "socket://localhost:8002"
	Protocol: sodep	
	Interfaces: StockInterface
}

inputPort MarketService {
	Location: "socket://localhost:8000"
	Protocol: sodep
	Interfaces: MarketInterface
}

execution{ concurrent}

init
{
  global.iStock=0;
  global.jPlayer = 0;
  global.numPlayer = 0;
  global.indexOro=0;
  global.indexGrano=1;
  global.indexPetrolio=2;

  global.contatoreLettoriOro = 0;
  global.contatoreLettoriGrano = 0;
  global.contatoreLettoriPetrolio = 0;
  global.acquistiFattiOro=0;
  global.acquistiFattiGrano=0;
  global.acquistiFattiPetrolio=0;

  //INIZIALIZZAZIONE SEMAFORI
  semRegistrazione.name = "Semaforo di Registrazione";
  release@SemaphoreUtils(semRegistrazione)(sResponse);

  mutexLetturaOro.name ="Semaforo Lettura Oro";
  release@SemaphoreUtils(mutexLetturaOro)(sResponse);

  mutexLetturaGrano.name ="Semaforo Lettura Grano";
  release@SemaphoreUtils(mutexLetturaGrano)(sResponse);

  mutexLetturaPetrolio.name ="Semaforo Lettura Petrolio";
  release@SemaphoreUtils(mutexLetturaPetrolio)(sResponse);

  semOro.name ="Semaforo stock Oro";
  release@SemaphoreUtils(semOro)(sResponse);

  semGrano.name ="Semaforo stock Grano";
  release@SemaphoreUtils(semGrano)(sResponse);

  semPetrolio.name ="Semaforo stock Petrolio";
  release@SemaphoreUtils(semPetrolio)(sResponse);

  semIndice.name= "Semaforo indice";
  release@SemaphoreUtils(semIndice)(sResponse)
}

//METODO LETTORE ORO
define startLetturaOro {
  acquire@SemaphoreUtils(mutexLetturaOro)(sResponse);
  global.contatoreLettoriOro++;
  if( global.contatoreLettoriOro == 1 ) {
    acquire@SemaphoreUtils(semOro)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaOro)(sResponse)  
}

define endLetturaOro
{
  acquire@SemaphoreUtils(mutexLetturaOro)(sResponse);
  global.contatoreLettoriOro--;
  if(global.contatoreLettoriOro == 0){
    release@SemaphoreUtils(semOro)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaOro)(sResponse)
}

//METODO LETTORE GRANO
define startLetturaGrano {
  acquire@SemaphoreUtils(mutexLetturaGrano)(sResponse);
  global.contatoreLettoriGrano++;
  if( global.contatoreLettoriGrano == 1 ) {
    acquire@SemaphoreUtils(semGrano)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaGrano)(sResponse)  
}

define endLetturaGrano
{
  acquire@SemaphoreUtils(mutexLetturaGrano)(sResponse);
  global.contatoreLettoriGrano--;
  if(global.contatoreLettoriGrano == 0){
    release@SemaphoreUtils(semGrano)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaGrano)(sResponse)
}
//METODO LETTORE PETROLIO
define startLetturaPetrolio {
  acquire@SemaphoreUtils(mutexLetturaPetrolio)(sResponse);
  global.contatoreLettoriPetrolio++;
  if( global.contatoreLettoriPetrolio == 1 ) {
    acquire@SemaphoreUtils(semPetrolio)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaPetrolio)(sResponse)  
}

define endLetturaPetrolio
{
  acquire@SemaphoreUtils(mutexLetturaPetrolio)(sResponse);
  global.contatoreLettoriPetrolio--;
  if(global.contatoreLettoriPetrolio == 0){
    release@SemaphoreUtils(semPetrolio)(sResponse)
  };
  release@SemaphoreUtils(mutexLetturaPetrolio)(sResponse)
}

main {   
    
    //Crea una Struttura Stock contenente tutti gli Stock registrati
    [creaStock(Stocks)(global.StockStructure){
      global.StockStructure.Value[global.iStock].name=Stocks.name;
      global.StockStructure.Value[global.iStock].price=Stocks.price;
      global.StockStructure.Value[global.iStock].available=Stocks.available;
      println@Console( "STOCK:\n" + global.StockStructure.Value[global.iStock].name + " creato\n°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
      global.iStock++
    }]


    //Memorizza una nuova istanza di Player e la memorizza nella struttura PlayersTot
    [creaPlayer(nomePlayer)(global.PlayersTot){

      acquire@SemaphoreUtils(semRegistrazione)(sResponse);

      global.PlayersTot.Player[global.numPlayer].name= nomePlayer;
      global.PlayersTot.Player[global.numPlayer].cash= double("100");
      global.PlayersTot.Player[global.numPlayer].stock[0].name = "";
      global.PlayersTot.Player[global.numPlayer].stock[0].price = 0;
      global.PlayersTot.Player[global.numPlayer].stock[0].possessed =0;
      global.PlayersTot.Player[global.numPlayer].stock[1].name = "";
      global.PlayersTot.Player[global.numPlayer].stock[1].price = 0;
      global.PlayersTot.Player[global.numPlayer].stock[1].possessed =0;
      global.PlayersTot.Player[global.numPlayer].stock[2].name = "";
      global.PlayersTot.Player[global.numPlayer].stock[2].price = 0;
      global.PlayersTot.Player[global.numPlayer].stock[2].possessed =0;
      
      release@SemaphoreUtils(semRegistrazione)(sResponse);

      println@Console("NEW PLAYER REGISTRATO: " +  global.PlayersTot.Player[global.numPlayer].name + "\n°°°°°°°°°°°°°°°°°°°°°°°°°\n")()
    }]

    //Invia l'indice di identificazione al Player
    [richiediIndex()(respost){
      acquire@SemaphoreUtils(semIndice)(sResponse);
      respost = global.numPlayer;
      global.numPlayer++;
      release@SemaphoreUtils(semIndice)(sResponse)
    }]

    //Input choice di stampa per l'identificazione del Player
    [stampaPlayer(global.PlayersTot)(respost){
    
      foreach ( Player : global.PlayersTot ) {
      respost =  "Player creato :"+"\n|"+ global.PlayersTot.Player[global.jPlayer].name+ 
                        "|\n|Cash: "+global.PlayersTot.Player[global.jPlayer].cash+"|\n";
      global.jPlayer++
    }
    }]

    //Ricevo visibilità dallo Stock Oro
    [oroTrue(boolean)(){
      global.oroVisible = boolean      
    }]
    //Ricevo visibilità dallo Stock Grano
    [granoTrue(boolean)(){
      global.granoVisible = boolean      
    }]
    //Ricevo visibilità dallo Stock Petrolio
    [petrolioTrue(boolean)(){
      global.petrolioVisible = boolean      
    }]

    //Richiesta del Player sulla visibilità degli Stocks
    [richiediStockVisibili()(stockDisponibili){
      stockDisponibili = false;
      if( global.oroVisible && global.granoVisible && global.petrolioVisible ) {
        stockDisponibili = true
      }else{
        stockDisponibili =false
      }     
    }]

    //Richiesta degli Stock da parte del Player
    [richiediStock()(global.StockStructure){
      startLetturaOro;
      richiestaDisponibilitaOro@Stock()(disponibilitaOro);
      global.StockStructure.Value[global.indexOro].available = disponibilitaOro;
      endLetturaOro;
      startLetturaGrano;
      richiestaDisponibilitaGrano@Stock()(disponibilitaGrano);
      global.StockStructure.Value[global.indexGrano].available = disponibilitaGrano;
      endLetturaGrano;
      startLetturaPetrolio;
      richiestaDisponibilitaPetrolio@Stock()(disponibilitaPetrolio);
      global.StockStructure.Value[global.indexPetrolio].available = disponibilitaPetrolio;
      endLetturaPetrolio
    }]
 
    //Richiesta del prezzo dell'oro da parte del Player
    [richiediPrezzoOro()(respostOro){
      startLetturaOro;
      richiestaDisponibilitaOro@Stock()(disponibilitaOro);
      if( disponibilitaOro>0 ) {
        respostOro = double((global.StockStructure.Value[global.indexOro].price)/(disponibilitaOro))
      }else
        respostOro = 0;
      endLetturaOro
    }]

    //Richiesta del prezzo del grano da parte del Player
    [richiediPrezzoGrano()(respostGrano){
      startLetturaGrano;
      richiestaDisponibilitaGrano@Stock()(disponibilitaGrano);
      if( disponibilitaGrano>0 ) {
        respostGrano = double((global.StockStructure.Value[global.indexGrano].price)/(disponibilitaGrano))
      }else
        respostGrano = 0;
      endLetturaGrano
    }]

    //Richiesta del prezzo del petrolio da parte del Player
    [richiediPrezzoPetrolio()(respostPetrolio){
      startLetturaPetrolio;
      richiestaDisponibilitaPetrolio@Stock()(disponibilitaPetrolio);
      if( disponibilitaPetrolio>0 ) {
        respostPetrolio = double((global.StockStructure.Value[global.indexPetrolio].price)/(disponibilitaPetrolio))
      }else
        respostPetrolio = 0;
      endLetturaPetrolio
    }]

    //Richiesta d'acquisto dell'oro da parte del Player, controllo se la disp è >0 e se
    //possiede cash sufficiente, in tal caso aggiorno il cash e il relativo stock posseduto del Player ed eseguo le operazioni
    //sul prezzo dell'oro, incrementandolo in base alla frequenza d'acquisto
    [acquistaOro(indexPlayer)(global.PlayersTot){
      //Acquisisco il LOCK sul Semaforo Stock Oro
      acquire@SemaphoreUtils(semOro)(sResponse);

      richiestaDisponibilitaOro@Stock()(disponibilitaOro);
      if( disponibilitaOro>0 ) {
         prezzoOro = double((global.StockStructure.Value[global.indexOro].price)/(disponibilitaOro));
          if ((global.PlayersTot.Player[indexPlayer].cash > prezzoOro)){
            //invio l'informazione di deperimento allo stock
            deperisciStockOro@Stock()(respost);
            //aggiorno lo stock Oro del Player
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].name = "ORO";
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].price = prezzoOro;
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].possessed++;
           
            //decrement l’Account del Player dell’attuale prezzo di un’unità di Oro 
            global.PlayersTot.Player[indexPlayer].cash = global.PlayersTot.Player[indexPlayer].cash - prezzoOro;

            println@Console( "|| PLAYER " + global.PlayersTot.Player[indexPlayer].name + " ← ORO || ")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();

            //viene preso l'istante preciso(in millisecondi) in cui il Player effettua l'operazione di acquistaOro
            getCurrentTimeMillis@Time()(tempoAcquistoOro);
            //i tempi vengono salvati in una lista di due posizoni
            //così da poter sottrarre l ultimo istante con quello precedente
            if( global.acquistiFattiOro==0) {
              global.listaTempi.global.listaOro[0]=tempoAcquistoOro;
              global.acquistiFattiOro++
            }else{
              global.listaTempi.global.listaOro[1]=tempoAcquistoOro;
              global.differenza=tempoAcquistoOro-global.listaTempi.global.listaOro[0];
              global.listaTempi.global.listaOro[0]=tempoAcquistoOro;
              global.acquistiFattiOro++;

              //A seconda dell'entità della differenza il prezzo attuale dell'oro
              //verrà moltiplicato per un valore temporale

              if( global.differenza>2000 ) {          
                moltiplicatoreTemporale1=double("0.01");
                delta1=double((global.StockStructure.Value[global.indexOro].price)*(moltiplicatoreTemporale1));
                valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexOro].price);
                global.StockStructure.Value[global.indexOro].price=valoreDopoAcquisto;
                println@Console( "|ORO   ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()

              }
              else if ( (global.differenza>=1000)&&(global.differenza<=2000) ) {    
                moltiplicatoreTemporale1=double("0.001");
                delta1=double((global.StockStructure.Value[global.indexOro].price)*(moltiplicatoreTemporale1));
                valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexOro].price);
                global.StockStructure.Value[global.indexOro].price=valoreDopoAcquisto;
                println@Console("|ORO    ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
              }
              else{
                moltiplicatoreTemporale1=double("0.001");
                delta1=double((global.StockStructure.Value[global.indexOro].price)*(moltiplicatoreTemporale1));
                valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexOro].price);
                global.StockStructure.Value[global.indexOro].price=valoreDopoAcquisto;
                println@Console( "|ORO   ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
                println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
              }
            };
              //Rilascio il LOCK
              release@SemaphoreUtils(semOro)(sResponse)
        }else {
          //Se il Player non ha abbastanza denaro gli viene negato l'acquisto
          println@Console( "Acquisto negato per mancanza di Cash" )();
          //Rilascio il LOCK
          release@SemaphoreUtils(semOro)(sResponse)
        }
      }else{
        //Se la disponibilità dello Stock è 0 viene negato l' acquisto al Player
        println@Console( "Acquisto negato per mancanza di Disponibilità" )();
        release@SemaphoreUtils(semOro)(sResponse)
      }   
    }]

    //Richiesta di vendita dell'oro da parte del Player, 
    //controllo i relativi stock posseduti del Player e li decremento della quantità venduta,
    //aggiorno il cash del Player ed eseguo le operazioni sul prezzo dell'oro, 
    //decrementandolo in base alla frequenza di vendita.
    [vendiOro(indexPlayer)(global.PlayersTot){
      //Acquisisco il LOCK sul Semaforo Stock Oro
      acquire@SemaphoreUtils(semOro)(sResponse);

      if( global.PlayersTot.Player[indexPlayer].stock[global.indexOro].possessed > 0 ) {
        //L'unità di stock Oro viene incrementata di 1
        incrementaStockOro@Stock()(respost);
        //Controllo se lo stock appena venduta fosse l'ultimo posseduto, n tal caso azzero lo stock posseduto
        if (global.PlayersTot.Player[indexPlayer].stock[global.indexOro].possessed==1){
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].name ="";
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].possessed = 0;
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].price = 0
        }else{
            global.PlayersTot.Player[indexPlayer].stock[global.indexOro].possessed--
        };    
        
        richiestaDisponibilitaOro@Stock()(disponibilitaOro);
        //Il nuovo prezzo dell'oro viene calcolato in base ai dati aggiornati
        prezzoOro = double((global.StockStructure.Value[global.indexOro].price)/(disponibilitaOro));

        global.PlayersTot.Player[indexPlayer].cash = global.PlayersTot.Player[indexPlayer].cash + prezzoOro;

        println@Console( "|| PLAYER " + global.PlayersTot.Player[indexPlayer].name + " ➔ ORO || ")();
        println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
        //viene preso l'istante preciso(in millisecondi) in cui il Player effettua l'operazione di vendiOro
        getCurrentTimeMillis@Time()(tempoVenditaOro);
        global.listaTempi.global.listaOro[1]=tempoVenditaOro;
        differenza=tempoVenditaOro-global.listaTempi.global.listaOro[0];
        //i tempi vengono salvati in una lista di due posizoni
        //così da poter sottrarre l ultimo istante con quello precedente
        if( differenza >=2000 ) {
            moltiplicatoreTemporale1=double("0.01");
            delta1=double((global.StockStructure.Value[global.indexOro].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double( global.StockStructure.Value[global.indexOro].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexOro].price=valoreDopoVendita;
            println@Console( "|ORO    ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
        }
        else if ( (differenza<=2000) && (differenza<=1000) ) {
            moltiplicatoreTemporale1=double("0.001");
            delta1=double((global.StockStructure.Value[global.indexOro].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double( global.StockStructure.Value[global.indexOro].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexOro].price=valoreDopoVendita;
            println@Console( "|ORO    ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
        }else{
            moltiplicatoreTemporale1=double("0.001");
            delta1=double((global.StockStructure.Value[global.indexOro].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double(global.StockStructure.Value[global.indexOro].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexOro].price=valoreDopoVendita;
            println@Console( "|ORO    ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
            
        };
      //Rilascio il LOCK
      release@SemaphoreUtils(semOro)(sResponse)
      }else{
        //Vendita negata poichè il Player non possiede alcuno Stock Oro
        println@Console( "Vendita negata!" )();
        release@SemaphoreUtils(semOro)(sResponse)
      }
    }]

    //Richiesta d'acquisto del Grano da parte del Player, controllo se la disp è >0 e se
    //possiede cash sufficiente, in tal caso aggiorno il cash e il relativo stock posseduto del Player ed eseguo le operazioni
    //sul prezzo del Grano, incrementandolo in base alla frequenza d'acquisto

    [acquistaGrano(indexPlayer)(global.PlayersTot){
      //Acquisisco il LOCK sul Semaforo Stock Grano
      acquire@SemaphoreUtils(semGrano)(sResponse);
      
      richiestaDisponibilitaGrano@Stock()(disponibilitaGrano);
      if( disponibilitaGrano>0 ) {
        prezzoGrano = double((global.StockStructure.Value[global.indexGrano].price)/(disponibilitaGrano));
        
        if(global.PlayersTot.Player[indexPlayer].cash > prezzoGrano ) {
        
          deperisciStockGrano@Stock()(respost);

          global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].name = "GRANO";
          global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].price = prezzoGrano;
          global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].possessed++;

          global.PlayersTot.Player[indexPlayer].cash= global.PlayersTot.Player[indexPlayer].cash - prezzoGrano;

          println@Console( "|| PLAYER " + global.PlayersTot.Player[indexPlayer].name + " ← GRANO || ")();
          println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
          //viene preso l'istante preciso in cui viene acquistato il grano
          getCurrentTimeMillis@Time()(tempoAcquistoGrano);
          //viene utilizzata lo stesso tipo di struttura dell'oro per salvare 
          //le tempistiche delle ultime due iterazioni
          if( global.acquistiFattiGrano==0) {
              global.listaTempi.global.listaGrano[0]=tempoAcquistoGrano;
              global.acquistiFattiGrano++
          }else{
              global.listaTempi.global.listaGrano[1]=tempoAcquistoGrano;
              global.differenza=tempoAcquistoGrano-global.listaTempi.global.listaGrano[0];
              global.listaTempi.global.listaGrano[0]=tempoAcquistoGrano;
              global.acquistiFattiGrano++;
          //A seconda dell'entità della differenza il prezzo attuale dell'oro
          //verrà moltiplicato per un valore temporale
              if( global.differenza>2000 ) {
                  
                  moltiplicatoreTemporale1=double("0.01");
                  delta1=double((global.StockStructure.Value[global.indexGrano].price)*(moltiplicatoreTemporale1));
                  valoreDopoAcquisto=double( delta1 + global.StockStructure.Value[global.indexGrano].price);
                  global.StockStructure.Value[global.indexGrano].price = valoreDopoAcquisto;
                  println@Console( "|GRANO    ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
                  println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
              }
              else if ( (global.differenza>=1000)&&(global.differenza<=2000) ) {
                  moltiplicatoreTemporale1=double("0.001");
                  delta1=double((global.StockStructure.Value[global.indexGrano].price)*(moltiplicatoreTemporale1));
                  valoreDopoAcquisto=double( delta1+global.StockStructure.Value[global.indexGrano].price);
                  global.StockStructure.Value[global.indexGrano].price=valoreDopoAcquisto;
                  println@Console( "|GRANO    ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
                  println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
              }
              else{
                  moltiplicatoreTemporale1=double("0.001");
                  delta1=double((global.StockStructure.Value[global.indexGrano].price)*(moltiplicatoreTemporale1));
                  valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexGrano].price);
                  global.StockStructure.Value[global.indexGrano].price=valoreDopoAcquisto;
                  println@Console( "|GRANO    ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
                  println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
              }
          };
          //Rilascio il LOCK
          release@SemaphoreUtils(semGrano)(sResponse)
        }else{
          //Acquisto negato poichè il Player non possiede denaro sufficiente
          println@Console( "Acquisto grano negato per mancanza di cash" )();
          //Rilascio il LOCK
          release@SemaphoreUtils(semGrano)(sResponse)
        }
      }else{
        //Acquisto negato poichè lo Stock Grano è nullo
        println@Console( "Acquisto negato per mancanza di disponibilita" )();
        //Rilascio il LOCK
        release@SemaphoreUtils(semGrano)(sResponse)
    }
    }]

    //Richiesta di vendita del grano da parte del Player,
    //controllo i relativi stock posseduti del Player e li decremento della quantità venduta,
    //aggiorno il cash del Player ed eseguo le operazioni sul prezzo del grano, 
    //decrementandolo in base alla frequenza di vendita.

    [vendiGrano(indexPlayer)(global.PlayersTot){
      //Acquisisco il lock sul Semaforo Stock Grano
      acquire@SemaphoreUtils(semGrano)(sResponse);


      if( global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].possessed > 0 ) {
        
        incrementaStockGrano@Stock()(respost);

        //Controllo se lo stock appena venduta fosse l'ultimo posseduto, n tal caso azzero lo stock posseduto
        if (global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].possessed==1){
            global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].name ="";
            global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].possessed = 0;
            global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].price = 0
        }else{
            global.PlayersTot.Player[indexPlayer].stock[global.indexGrano].possessed--
        };    
        
        richiestaDisponibilitaGrano@Stock()(disponibilitaGrano);
        //Il nuovo prezzo del grano viene calcolato in base ai dati aggiornati
        prezzoGrano = double((global.StockStructure.Value[global.indexGrano].price)/(disponibilitaGrano));

        global.PlayersTot.Player[indexPlayer].cash = global.PlayersTot.Player[indexPlayer].cash + prezzoGrano;
        
        println@Console( "|| PLAYER " + global.PlayersTot.Player[indexPlayer].name + " ➔ GRANO || ")();
        println@Console( "------------------------- \n" )();
        //viene preso l'istante preciso in cui viene acquistato il grano
        getCurrentTimeMillis@Time()(tempoVenditaGrano);
        global.listaTempi.global.listaGrano[1]=tempoVenditaGrano;
        differenza=tempoVenditaGrano-global.listaTempi.global.listaGrano[0];

        if( differenza >=2000 ) {
            moltiplicatoreTemporale1=double("0.01");
            delta1=double((global.StockStructure.Value[global.indexGrano].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double( global.StockStructure.Value[global.indexGrano].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexGrano].price=valoreDopoVendita;
            println@Console( "|GRANO    ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
        }
        else if ( (differenza<=2000) && (differenza<=1000) ) {
          moltiplicatoreTemporale1=double("0.001");
            delta1=double((global.StockStructure.Value[global.indexGrano].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double(global.StockStructure.Value[global.indexGrano].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexGrano].price=valoreDopoVendita;
            println@Console( "|GRANO   ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
        }
        else{

          moltiplicatoreTemporale1=double("0.001");
            delta1=double((global.StockStructure.Value[global.indexGrano].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double(global.StockStructure.Value[global.indexGrano].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexGrano].price=valoreDopoVendita;
            println@Console( "|GRANO   ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
            
        };
        //Rilascio il LOCK
        release@SemaphoreUtils(semGrano)(sResponse)
      }else{
        println@Console( "Vendita Grano negata!" )();
        //Rilascio il LOCK
        release@SemaphoreUtils(semGrano)(sResponse)
      }
    }]

    //Richiesta d'acquisto del Petrolio da parte del Player, controllo se la disp è >0 e se
    //possiede cash sufficiente, in tal caso aggiorno il cash e il relativo stock posseduto del Player ed eseguo le operazioni
    //sul prezzo del Petrolio, incrementandolo in base alla frequenza d'acquisto
    [acquistaPetrolio(indexPlayer)(global.PlayersTot){
      //Acquisisco il LOCK sul Semaforo Stock Petrolio
      acquire@SemaphoreUtils(semPetrolio)(sResponse);

      richiestaDisponibilitaPetrolio@Stock()(disponibilitaPetrolio);
      //Controllo che la disp sia positivia, in tal caso calcolo il prezzo
      if( disponibilitaPetrolio>0 ) {
        prezzoPetrolio = double((global.StockStructure.Value[global.indexPetrolio].price)/(disponibilitaPetrolio));
        
        if(global.PlayersTot.Player[indexPlayer].cash > prezzoPetrolio) {

          deperisciStockPetrolio@Stock()(respost);
          
          global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].name = "PETROLIO";
          global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].price = prezzoPetrolio;
          global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].possessed++;
          
          global.PlayersTot.Player[indexPlayer].cash= global.PlayersTot.Player[indexPlayer].cash - prezzoPetrolio;

          println@Console( "|| PLAYER " + global.PlayersTot.Player[indexPlayer].name + " ← PETROLIO || ")();
          println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
          //viene preso l'istante preciso in cui viene acquistato il petrolio
          getCurrentTimeMillis@Time()(tempoAcquistoPetrolio);

          if( global.acquistiFattiPetrolio==0) {
            global.listaTempi.global.listaPetrolio[0]=tempoAcquistoPetrolio;
            global.acquistiFattiPetrolio++
          }else{
            global.listaTempi.global.listaPetrolio[1]=tempoAcquistoPetrolio;
            global.differenza=tempoAcquistoPetrolio-global.listaTempi.global.listaPetrolio[0];
            global.listaTempi.global.listaPetrolio[0]=tempoAcquistoPetrolio;
            global.acquistiFattiPetrolio++;

            if( global.differenza>2000 ) {
              moltiplicatoreTemporale1=double("0.01");
              delta1=double((global.StockStructure.Value[global.indexPetrolio].price)*(moltiplicatoreTemporale1));
              valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexPetrolio].price);
              global.StockStructure.Value[global.indexPetrolio].price=valoreDopoAcquisto;
              println@Console( "|PETROLIO   ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
              println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()

            }
            else if ( (global.differenza>=1000)&&(global.differenza<=2000) ) {
              moltiplicatoreTemporale1=double("0.001");
              delta1=double((global.StockStructure.Value[global.indexPetrolio].price)*(moltiplicatoreTemporale1));
              valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexPetrolio].price);
              global.StockStructure.Value[global.indexPetrolio].price=valoreDopoAcquisto;
              println@Console( "|PETROLIO   ⬆︎ "+ delta1 +" |\n| €:     "+valoreDopoAcquisto +"|")();
              println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
            }
            else{
              moltiplicatoreTemporale1=double("0.001");
              delta1=double((global.StockStructure.Value[global.indexPetrolio].price)*(moltiplicatoreTemporale1));
              valoreDopoAcquisto=double( delta1+ global.StockStructure.Value[global.indexPetrolio].price);
              global.StockStructure.Value[global.indexPetrolio].price=valoreDopoAcquisto;
              println@Console( "|PETROLIO   ⬆︎ "+ delta1 +" |\n| €:     "+ valoreDopoAcquisto +"|")();
              println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
            }
        };
        //Rilascio il LOCK
        release@SemaphoreUtils(semPetrolio)(sResponse)
        }else{
          //Acquisto negato per mancanza di denaro 
          println@Console( "Acquisto Petrolio negato per mancanza di cash" )();
          release@SemaphoreUtils(semPetrolio)(sResponse)
        }
      }else{
        //Acquisto negato per disponibilità petrolio nulla
        println@Console( "Acquisto negato per mancanza di Disponibilità" )();
        //Rilascio LOCK
        release@SemaphoreUtils(semPetrolio)(sResponse)
      }
    }]

    //Richiesta di vendita del Petrolio da parte del Player,
    //controllo i relativi stock posseduti del Player e li decremento della quantità venduta,
    //aggiorno il cash del Player ed eseguo le operazioni sul prezzo del petrolio, 
    //decrementandolo in base alla frequenza di vendita.
    [vendiPetrolio(indexPlayer)(global.PlayersTot){
      //Acquisisco il LOCK sul Semaforo Stock Petrolio 
      acquire@SemaphoreUtils(semPetrolio)(sResponse);
      if( global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].possessed >0 ) {
        incrementaStockPetrolio@Stock()(respost);

        if (global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].possessed==1){
            global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].name ="";
            global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].possessed = 0;
            global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].price = 0
        } else {
            global.PlayersTot.Player[indexPlayer].stock[global.indexPetrolio].possessed--
        };  
        
        //Calcolo il prezzo con la disponibilità aggiornata
        richiestaDisponibilitaPetrolio@Stock()(disponibilitaPetrolio);
        prezzoPetrolio = double((global.StockStructure.Value[global.indexPetrolio].price)/(disponibilitaPetrolio));
        
        global.PlayersTot.Player[indexPlayer].cash = global.PlayersTot.Player[indexPlayer].cash + prezzoPetrolio;
        
        println@Console( "|| Player " + global.PlayersTot.Player[indexPlayer].name + " ➔ PETROLIO || ")();
        println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
        //viene preso l'istante preciso in cui viene venduto il petrolio
        getCurrentTimeMillis@Time()(tempoVenditaPetrolio);
        global.listaTempi.global.listaPetrolio[1]=tempoVenditaPetrolio;
        differenza=tempoVenditaPetrolio-global.listaTempi.global.listaPetrolio[0];
        
        if( differenza >=2000 ) {
            moltiplicatoreTemporale1=double("0.01");
            delta1=double((global.StockStructure.Value[global.indexPetrolio].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double( global.StockStructure.Value[global.indexPetrolio].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexPetrolio].price=valoreDopoVendita;
            println@Console( "|PETROLIO   ⬇ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
        }
        else if ( (differenza<=2000) && (differenza<=1000) ) {
            moltiplicatoreTemporale1=double("0.001");
            delta1=double((global.StockStructure.Value[global.indexPetrolio].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double( global.StockStructure.Value[global.indexPetrolio].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexPetrolio].price=valoreDopoVendita;
            println@Console( "|PETROLIO   ⬇ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()
            }
        else{
            moltiplicatoreTemporale1=double("0.001");
            delta1=double((global.StockStructure.Value[global.indexPetrolio].price)*(moltiplicatoreTemporale1));
            valoreDopoVendita=double(global.StockStructure.Value[global.indexPetrolio].price-delta1);
            if( valoreDopoVendita<10 ) {
              valoreDopoVendita = double(10)
            };
            global.StockStructure.Value[global.indexPetrolio].price=valoreDopoVendita;
            println@Console( "|PETROLIO   ⬇︎ "+ delta1 +" |\n| €:     "+valoreDopoVendita +"|")();
            println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )()   
            };
        //Rilascio il LOCk
        release@SemaphoreUtils(semPetrolio)(sResponse)
      }else{
        //Vendita petrolio negata per mancanza di stock posseduto
        println@Console( "Vendita Petrolio negata!" )();
        //Rilascio il LOCK
        release@SemaphoreUtils(semPetrolio)(sResponse)
      }
    }]

    //Il Market riceve in input il valore dell'incremento dell'oro
    //tale valore viene usato dal Market per calcolare il nuovo prezzo dell'Oro 
    [inviaIncrementoOro(nIncremento)(){
      acquire@SemaphoreUtils(semOro)(sResponse);
      nIncr = double(nIncremento);
      oldPrice = double(global.StockStructure.Value[global.indexOro].price);
      newPrice = double(oldPrice - (oldPrice*nIncr));
      //il prezzo di uno stock non può essere inferiore a 10€ 
      if( newPrice < 10 ) {
          newPrice = double(10)
      };
      global.StockStructure.Value[global.indexOro].price = newPrice;
      println@Console("|ORO    ↑ "+ nIncr +"|\n| €:     " + global.StockStructure.Value[global.indexOro].price+ "|")();
      println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
      release@SemaphoreUtils(semOro)(sResponse)
    }]

    //Il Market riceve in input il valore dell'incremento del grano
    //tale valore viene usato dal Market per calcolarne il nuovo prezzo
    //A seconda che avvenga un incremento o un decremento il prezzo si abbassa o sale
    [inviaIncrementoGrano(nIncremento)(){
      acquire@SemaphoreUtils(semGrano)(sResponse);
      nIncr = double(nIncremento);
      oldPrice = double(global.StockStructure.Value[global.indexGrano].price);
      newPrice = double(oldPrice - (oldPrice*nIncr));
      //il prezzo di uno stock non può essere inferiore a 10€ 
      if( newPrice < 10 ) {
          newPrice = double(10)
      }; 
      global.StockStructure.Value[global.indexGrano].price = newPrice;
      println@Console("|GRANO    ↑ "+ nIncr +"|\n| €:     " + global.StockStructure.Value[global.indexGrano].price+ "|")();
      println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
      release@SemaphoreUtils(semGrano)(sResponse)
    }]

    //Il Market riceve in input il valore del decremento del grano
    //tale valore viene usato dal Market per calcolarne il nuovo prezzo
    [inviaDecrementoGrano(nDecremento)(){
      acquire@SemaphoreUtils(semGrano)(sResponse);
      nDecr = double(nDecremento);
      oldPrice = double(global.StockStructure.Value[global.indexGrano].price);
      newPrice = double(oldPrice + (oldPrice*nDecr)); 
      global.StockStructure.Value[global.indexGrano].price = newPrice;
      println@Console("|GRANO    ↓ "+ nDecr +"|\n| €:     " + global.StockStructure.Value[global.indexGrano].price+ "|")();
      println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
      release@SemaphoreUtils(semGrano)(sResponse)
    }]

    //Il Market riceve in input il valore del decremento del petrolio
    //tale valore viene usato dal Market per calcolarne il nuovo prezzo
    [inviaIncrementoPetrolio(nIncremento)(){
      acquire@SemaphoreUtils(semPetrolio)(sResponse);
      nIncr = double(nIncremento);
      oldPrice = double(global.StockStructure.Value[global.indexPetrolio].price);
      newPrice = double(oldPrice - (oldPrice*nIncr));
      //il prezzo di uno stock non può essere inferiore a 10€
      if( newPrice < 10 ) {
          newPrice = double(10)
      };
      global.StockStructure.Value[global.indexPetrolio].price = newPrice;
      println@Console( "|PETROLIO    ↑ "+ nIncr +"|\n| €:     " + global.StockStructure.Value[global.indexPetrolio].price+ "|")();
      println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
      release@SemaphoreUtils(semPetrolio)(sResponse)
    }]

    //Il Market riceve in input il valore dell'incremento del petrolio
    //tale valore viene usato dal Market per calcolarne il nuovo prezzo
    [inviaDecrementoPetrolio(nDecremento)(){
      acquire@SemaphoreUtils(semPetrolio)(sResponse);
      nDecr = double(nDecremento);
      oldPrice = double(global.StockStructure.Value[global.indexPetrolio].price);
      newPrice = double(oldPrice + (oldPrice*nDecr)); 
      global.StockStructure.Value[global.indexPetrolio].price = newPrice;
      println@Console( "|PETROLIO    ↓ "+ nDecr +"|\n| €:     " + global.StockStructure.Value[global.indexPetrolio].price+ "|")();
      println@Console( "°°°°°°°°°°°°°°°°°°°°°°°°°\n" )();
      release@SemaphoreUtils(semPetrolio)(sResponse)
    }]

}
