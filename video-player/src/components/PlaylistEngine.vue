<template>
  <div>
    <div v-if="this.source !='B14'" class="titles">
      <h2 class="fr no-select">{{title_fr}}</h2>
      <h2 class="en no-select">{{title_en}}</h2>
      <div v-if="this.source == 'BNS'" class="BNSHeader" />
    </div>
    <div v-else class="B14Header"></div>

    <player-button 
      v-if="isInMetaViewContext" 
      v-on:clickEvt="backToMetaView" 
      touchEnabled=false
      class="back" 
      iconType="back"/>

    <div class="content" v-bind:style="bindStyle">
      <!-- <h1>{{playlist.title.fr}}</h1> -->
      <div class="grid" ref="grid">
        <div class="clip" v-bind:style="clipStyle" v-for="clip in playlist.clips" :key="clip.id">
          <div class="title" v-bind:style="clipTitleStyle">
            <div class="lang-fr no-select">{{clip.title.fr}}</div>
            <div class="lang-en no-select">{{clip.title.en}}</div>
            
          </div>
          <div class="thumbnail">
            <img class="thumbnail no-select" v-bind:style="thumbnailStyle" draggable="false" :src="clip.thumbnail"  />
            <div v-if="isTranslatable" class="zone">
              <div class="left" @click="onPlay(clip, 'fr')">
                <div class="lang-fr no-select">FR</div>
              </div>
              <div class="right" @click="onPlay(clip, 'en')">
                <div class="lang-en no-select">EN</div>
              </div>
            </div>
            <div v-else class="zone no-select" @click="onPlay(clip, 'fr')"></div>
          </div>
          
          
          <div class="description">
            <div class="lang-fr">
              <div class="main no-select" v-html="clip.descriptionMain.fr"></div>
              <div class="secondary no-select" v-html="clip.descriptionSecondary.fr"></div>
            </div>
            <div class="lang-en">
              <div class="main no-select" v-html="clip.descriptionMain.en"></div>
              <div class="secondary no-select" v-html="clip.descriptionSecondary.en"></div>
            </div>
          </div>
        </div>
      </div>
      <video-player 
        v-if="clipUrl" 
        :url="clipUrl" 
        ref="videoPlayer" 
        :translatable="source != 'B14'"
        v-on:onClose="onClose"
        v-on:timeoutEvt="onVideoPlayerTimeout"/>
    </div>
  </div>
</template>

<style scoped lang="scss">

  .back{
    position: fixed;
    top: 0;
    left: 0;
  }
  div.titles{
    margin-top: 80px;
    margin-bottom: 80px;
    .fr{
      color: white;
      margin:0;
      padding:0;
    }

    .en{
      color: #c6c6c6;
      margin:0;
      padding:0;
    }
  }

  div.B14Header{
    height: 24vh;
  }
  
  div.BNSHeader{
    height: 11vh;
  }

  .content{
    background-color: black;
    color: white;
    margin: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    margin-left: auto;
    margin-right: auto;
    video-player {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 2;
    }

    .grid{
      display: flex;
      align-content: center;
      justify-content: center;
      align-items: center;
      flex-direction: row;
      flex-wrap: wrap;

      .clip{
        flex: 0 0 280px;
        width: 280px;
        margin: 8px;
        overflow: hidden;
        div.thumbnail{
          width: 100%;
          position: relative;
          .zone{
            display: flex;
            position: absolute;
            width: 281px; // hack
            top: 0px;
            left: 0;
            right: 0;
            bottom: 4px;
            overflow: hidden;
            .left{
              width: calc(50% - 3px);
              border: 2px solid black;
              border-right: 1px solid black;
              height: calc(100% - 4px);
              .lang-fr {
                position: absolute;
                left: 0;
                top: 43%;
                font-size: 80%;
                padding: 3px;
                background-color: black;
                color: white;
              }
            }
            .right{
              width: calc(50% - 3px);
              border: 2px solid black;
              border-left: 1px solid black;
              height: calc(100% - 4px);
              .lang-en {
                position: absolute;
                right: 0;
                top: 43%;
                font-size: 80%;
                padding: 3px;
                background-color: black;
                color: #c6c6c6;
              }
            }
          }
        }
        div.title{
          height: 86px;
          font-weight: 800;
          font-size: 15px;
          text-align: left;
          display: flex;
          align-content: flex-end;
          align-items: flex-start;
          justify-content: flex-end;
          flex-direction: column;
          padding-bottom: 5px;
          .lang-fr{
            padding: 2px;
          }
          .lang-en{
            padding: 2px;
            color: #aaa;
          }
        }

        div.description{
          text-align: left;
          height: 78px;
          font-size: 11.5px;
          display: flex;
          .lang-fr{
            padding: 2px;
            width: 49%;
            .main{
              font-weight: 800;
            }
          }
          .lang-en{
            padding: 2px;
            color: #aaa;
            width: 49%;
            .main{
              font-weight: 800;
            }
          }

        }
      }

    }
  }    
</style>


<script lang="ts">
import { Component, Prop, Vue } from "vue-property-decorator";
import { $config, $content } from "@/services";
import { MEG } from "../models";

import VideoPlayer from '@/components/VideoPlayer.vue'; // @ is an alias to /src
import PlayerButton from "@/components/PlayerButton.vue";
import Timer from '@/helpers/Timer';

@Component({
  components: {
    VideoPlayer, PlayerButton,
  },
})
export default class PlaylistEngine extends Vue {
  @Prop({default:'A'}) source!: string;
  @Prop({default: false}) hasTimer!: boolean;
  @Prop({default: false}) isInMetaViewContext!: boolean;

  debounceTimerId: number = -1;
  backIsLocked: boolean = false;

  clipUrl: string|null = null;
  clip: MEG.Clip|null = null;

  timer?: Timer = undefined;

  get config() {
    return $config.config;
  }

  get isTranslatable(): boolean{
    return this.source != "B14";
  }

  get playlist() :MEG.Playlist {
    const list = $content.getPlaylistForId(this.source);
    return list as MEG.Playlist;
  }

  get title_fr(): string{
    return this.playlist.title.fr || "";
  }
  
  get title_en(): string{
    return this.playlist.title.en || "";
  }

  get bindStyle() {
    const clips = this.playlist.clips.length;
    const maxWidth = (clips > 9) ? 1920:((clips == 9)? 1500:1200);

    return { 
      maxWidth: maxWidth + 'px'
    };
  }

  get clipTitleStyle(){
    if(this.source == "B14"){
      return {
        height: "140px",
      };
    }
    
    if(this.source == "A"){
      return {
        height: "110px",
      };
    }
    return {};
  }

  get clipStyle(){
    if(this.source == "B14"){
      return {
        width: "350px",
        flex: "0 0 350px",
        margin: "25px",
      };
    }
    return {};
  }

  get thumbnailStyle(){
    if(this.source == "B14"){
      return {
        width: "100%"
      };
    }
    return {};
  }

  mounted() {
    if(this.hasTimer){
      this.timer = new Timer(this.config.timeout_duration_ms, this.onTimeout.bind(this));
      this.timer?.start();
    }
  }

  beforeDestroy() {
    if(this.hasTimer){
      this.timer?.stop();
    }
  }

  onTimeout(){
    this.$emit("timeoutEvt", {});
  }

  onPlay(clip:MEG.Clip, lang: string="fr") {
    if(this.hasTimer){
      this.timer?.stop();
    }
    this.clip = clip;
    this.clipUrl = lang == MEG.Lang.FR ? this.clip.clip.fr : this.clip.clip.en;
  }

  onClose() {
    this.clipUrl=null;
    if(this.hasTimer){
      this.timer?.start();
    }

    if(this.isInMetaViewContext){
      this.backIsLocked = true;
      window.clearTimeout(this.debounceTimerId);
      window.setTimeout(() =>{
        this.backIsLocked = false;
      }, this.config.back_click_delay);
    }
  }

  backToMetaView(){
    if(this.backIsLocked) return;

    this.$emit("backRequestEvt", {});
  }

  onVideoPlayerTimeout(){
    if(this.hasTimer){
      this.onTimeout();
    }else{
      this.clipUrl = null;
    }
  }
}
</script>
