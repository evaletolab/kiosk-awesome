<template>
  <div class="">
    <div class="backdrop"/>

    <div class="player">
      <!-- ui overlay  -->
      <div class="overlay">
        <player-button v-on:clickEvt="broadcastCloseRequest" touchEnabled=false class="back" iconType="back"/>
    
        <div class="left-controls">
          <player-button v-on:clickEvt="decreaseVolume" iconType="volume_min"/>
          <player-button v-on:clickEvt="increaseVolume" iconType="volume_plus"/>
          <player-button v-on:clickEvt="onPlay" iconType="play" :selected="isPlaying"/>
          <player-button v-on:clickEvt="onPause" iconType="pause" :selected="!isPlaying"/>
        </div>

        <div class="lang-buttons">
          <lang-button 
            v-if="translatable" 
            touchEnabled=false
            lang="fr" 
            :selected="lang != 'fr'"
            v-on:requestLang="onLanguageChangeRequest"/>
          <lang-button 
            v-if="translatable" 
            touchEnabled=false
            lang="en" 
            :selected="lang != 'en'"
            v-on:requestLang="onLanguageChangeRequest"/>
        </div>
    
        <div class="time-display no-select">
          <div class="time-text no-select">
            {{elapsedStr}} / {{durationStr}}
          </div>
        </div>
      </div>

      <!-- video element -->
      <video ref="player" autoplay>
        <source :src="url" type="video/mp4"/>
      </video>
    </div>
  </div>
</template>

<style scoped>
.player{
  position: fixed;
  z-index: 3;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
}

.overlay{
  z-index: 5;
}

video {
  width: 100%;
  height: 100%;
  z-index: 4;
}

.back{
  position:absolute;
  top:0;
  left:0;
  z-index: 2;

}

.time-display{
  position: absolute;
  width: 210px;
  height: 65px;
  bottom:0;
  left: calc(50vw - 105px);
  background-color: black;
}

.time-display .time-text{
  color:white;
  font-size: 26px;
  padding-top: 15px;
}

.left-controls{
  position: absolute;
  /* bottom: 0; */
  top: 30vh;
  left: 0;
  z-index: 2;
}

.lang-buttons{
  position: absolute;
  right: 0;
  top: 42vh;
  z-index: 10;
}

.backdrop{
  position: fixed;
  z-index: 1;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: black;
}
</style>


<script lang="ts">
import { Component, Vue, Prop } from "vue-property-decorator";
import { $config } from "@/services";
import { formatTime } from "@/helpers/timeHelpers";
import { MEG } from "@/models";
import Timer from "@/helpers/Timer";
import PlayerButton from "@/components/PlayerButton.vue";
import LangButton from "@/components/LangButton.vue";

@Component({
  components: { PlayerButton, LangButton },
})
export default class VideoPlayer extends Vue {

  @Prop() url!: string;
  @Prop({default: true}) translatable!: boolean;
  currentPosition = 0;

  isReadyToPlay = false;
  isPlaying = true;
  isLoading = false;
  duration = 0;
  elapsed = 0;

  langWasChanged:boolean = false;

  timer!: Timer;

  lang: MEG.Lang = MEG.Lang.FR;

  get config() {
    return $config.config;
  }

  get video() {
    return this.$refs.player as HTMLVideoElement;
  }

  get elapsedStr(){
    return formatTime(this.elapsed);
  }

  get durationStr(){
    return formatTime(this.duration);
  }
  
  computeCurrentLang(): MEG.Lang{
    let ext = null;

    if(this.langWasChanged){
      // console.log("lang was changed", this.video.src);
      ext = this.video.src.slice(this.video.src.length - 6, this.video.src.length - 4);
    }else{
      ext = this.url.slice(this.url.length - 6, this.url.length - 4);
    }

    // console.log("got ext", ext);

    if(ext.toUpperCase() == "FR"){
      return MEG.Lang.FR;
    }else{
      return MEG.Lang.EN;
    }
  }

  mounted() {
    this.timer = new Timer(this.config.timeout_duration_ms, this.onTimeout.bind(this));
    this.lang = this.computeCurrentLang();

    this.addListeners();

    this.video.volume = this.config.volume.default;
  }

  onTimeout(){
    this.$emit("timeoutEvt", {});
  }

  addListeners(){
    this.video.addEventListener("ended", this.onTrackEnded);
    this.video.addEventListener("timeupdate", this.onTimeUpdate);
    this.video.addEventListener("loadedmetadata", this.onMetaLoaded);
    this.video.addEventListener("waiting", this.onWait);
    this.video.addEventListener("canplay", this.onCanPlay);
  }
  
  removeListeners(){
    this.video.removeEventListener("ended", this.onTrackEnded);
    this.video.removeEventListener("timeupdate", this.onTimeUpdate);
    this.video.removeEventListener("loadedmetadata", this.onMetaLoaded);
    this.video.removeEventListener("waiting", this.onWait);
    this.video.removeEventListener("canplay", this.onCanPlay);
  }

  beforeDestroy() {
    //
    // remove timer
    this.timer.stop();
    this.removeListeners();
  }

  onMetaLoaded() {
    this.duration = Math.floor(this.video.duration);
    this.elapsed = 0;

    // ISSUE on iOS
    // https://stackoverflow.com/questions/50051639/javascript-html5-video-event-canplay-not-firing-on-safari
    this.isLoading = false;
  }

  onTrackEnded() {
    this.isPlaying = false;
    this.broadcastCloseRequest();
  }

  onTimeUpdate() {
    this.elapsed = Math.floor(this.video.currentTime);
  }
  
  onLanguageChangeRequest(e: any){
    if(!this.isPlaying) this.timer.reset();


    const lang = this.computeCurrentLang();
    const newLang = e.requestedLang;

    if(lang == newLang){
      // do noting if click on current lang 
      return ;
    }

    console.log("current lang, new lang", lang, newLang);

    const newUrl = `${this.url.substring(0, this.url.length - 7)}_${newLang.toString().toUpperCase()}.mp4`;

    this.video.src = newUrl;
    this.video.currentTime = 0;
    this.video.play();
    this.isPlaying = true;

    this.langWasChanged = true;
    this.lang = newLang;
  }

  // pause request
  onPause() {
    this.timer.reset();
    if (!this.isPlaying) return;

    this.video.pause();
    this.isPlaying = false;
  }

  // play request
  onPlay() {
    this.timer.stop();

    if (this.isPlaying) return;

    this.video.play();
    this.isPlaying = true;
    this.isReadyToPlay = true;
  }

  onSeekForwards() {
    this.video.currentTime = Math.min(
      this.video.currentTime + 10,
      this.video.duration
    );
  }

  onSeekBackwards() {
    this.video.currentTime = Math.max(this.video.currentTime - 10, 0);
  }

  onloaded() {}

  onWait() {
    this.isReadyToPlay = false;
    this.isLoading = true;
    console.log("--DBG onWait for data");
  }

  onCanPlay() {
    this.isLoading = false;
    // this.onPlay();
  }

  increaseVolume(e?:Event){
    if(!this.isPlaying) this.timer.reset();

    this.video.volume = Math.min(this.config.volume.max, this.video.volume + this.config.volume.step);
  }

  decreaseVolume(e?:Event){
    if(!this.isPlaying) this.timer.reset();
    
    this.video.volume = Math.max(this.config.volume.min, this.video.volume - this.config.volume.step);
  }

  broadcastCloseRequest(){
    this.$emit("onClose",{});
  }
}
</script>
