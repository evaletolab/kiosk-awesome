export default class Timer {
    private _running: boolean = false;

    private _timeoutId: number = -1;

    constructor(private _duration: number = 20000, private _cb:() => void){ }

    get duration(): number{
        return this._duration;
    }

    start(){
        if(this._running) return;

        this._running = true;

        this._timeoutId = window.setTimeout(() => {
            // console.log("timeout------------------------------------------------------");
            if(this._cb){
                this._cb();
            }
        }, this._duration);
    }

    reset(){
        this.stop();
        this.start();
    }

    stop(){
        if(!this._running) return;

        this._running = false;
        window.clearTimeout(this._timeoutId);
    }
}