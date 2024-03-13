import { MEG } from "@/models";
import axios from 'axios';


function getAxiosOptions(){

  return {
    headers: { 
      'Cache-Control': 'no-cache',
      'Content-Type': 'application/json',
    }
  };
}


class ContentService {
  private _data: any;
  private playlists: Map<MEG.Id, MEG.Playlist> = new Map<MEG.Id, MEG.Playlist>();

  public async load(){
    console.log("cms-service load all");
    const config = Object.assign({}, getAxiosOptions()) as any;

    const url = '/data.json';
    this._data = (await axios.get(url, config)).data;

    console.log("got data", this._data);

    this.processPlaylists();
    
  }

  processPlaylists(){
    const playlistDataMap = this._data.playlists;
    for(const [key, value] of Object.entries(playlistDataMap)){
      const playlist = new MEG.Playlist(key, value);
      this.playlists.set(key, playlist);
    }
  }

  getPlaylistForId(id: MEG.Id) : MEG.Playlist | null{
    if(!this.playlists.has(id)){
      console.error("there is no playlist with id", id);
      return null;
    }
    return this.playlists.get(id) as MEG.Playlist;
  }

}

//
// services start with $
export const $content = new ContentService();