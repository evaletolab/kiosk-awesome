<template>
  <div></div>
</template>

<style lang="scss" scoped>
  .thumb{
    width: 200px;
    height: 100px;
  }
</style>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import { $config } from "@/services";
import HelloWorld from '@/components/HelloWorld.vue'; // @ is an alias to /src
import VideoPlayer from '@/components/VideoPlayer.vue'; // @ is an alias to /src

import VideoThumbnail from '@/components/VideoThumbnail.vue';

@Component({
  components: {
    VideoPlayer, VideoThumbnail
  },
})
export default class Home extends Vue {

  playVideo: boolean = false;
  
  get config() {
    return $config.config;
  }

  mounted(){

    if(!this.config.show_cursor){
      document.body.parentElement!.style.cursor = "none";
    }

    const action = this.config.boot_action;
    if(action){
      if(action == "meta"){
        this.$router.push({path: "MetaView"});
      }else{
        this.$router.push({path: "Playlist", query: {playlist: action}});
      }
    }else{
      // default behavior
      this.$router.push({path: "Playlist", query: {playlist: "A"}});
    }
  }

  onVideoSelectionRequest(e:any){
    this.playVideo = true;
  }

  videoPlayerRequestsClosing(){
    this.playVideo = false;
  }
}
</script>
