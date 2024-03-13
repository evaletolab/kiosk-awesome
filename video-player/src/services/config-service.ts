import Vue from "vue";
import axios from 'axios';

const defaultAxios = {
  headers: { 'Cache-Control': 'no-cache' }
};

class ConfigService {
  // More about store
  // https://fr.vuejs.org/v2/guide/reactivity.html
  private _store: any;
  private _baseUrl = process.env.BASE_URL;
  private _isInstalled = false;

  lang = 'fr';
 
  constructor() {
    this._store = Vue.observable({
      config: {}
    });

  }

  get store() {
    return this._store;
  }

  get config() {
    return this._store.config;
  }

  async get(force?: boolean){
    if(!this._store.config.done && !force) {
      const res = await axios.get(this._baseUrl + 'config.json',defaultAxios);
      this._store.config = res.data;
      this._store.config.done = true;
    }

    return this._store.config;
  }  
  

  //
  // Detects if device is on iOS
  isIos() {
    const userAgent = window.navigator.userAgent.toLowerCase();
    return /iphone|ipad|ipod/.test( userAgent ) ;
  }

  //
  // is Safari
  isSafari() {
    const userAgent = navigator.userAgent.toLowerCase();
    return /^((?!chrome|android).)*safari/i.test(userAgent);
  }

  isAndroid() {
    const userAgent = navigator.userAgent.toLowerCase();
    return /android/i.test(userAgent);
  }

  //
  // Detects if device is in standalone mode
  isInStandaloneMode(){ 
    const $window = window as any;    
    const standalone = (window.matchMedia('(display-mode: standalone)').matches);
    return ($window.navigator.standalone) || standalone || this._isInstalled;
  }


  async storageGet(key: string) {
    return new Promise((resolve, reject) => {
      try {
        const item = localStorage.getItem(key);
        const parsed = JSON.parse(item as string);
        resolve(parsed);
      } catch (err) {
        return reject(err);
      }
    });
  }

  async storageSet(key: string, value: any) {
    return new Promise((resolve, reject) => {
      try {
        localStorage.setItem(key, JSON.stringify(value));
        resolve(value);
      } catch (err) {
        reject(err);
      }
    });
  }
}


//
// service start with $
export const $config = new ConfigService();