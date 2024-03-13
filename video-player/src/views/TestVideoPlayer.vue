<template>
  <div class="home">
    <video-thumbnail v-on:videoSelectionRequest="onVideoSelectionRequest" class="thumb"/>
    <video-player :url="videoUrl" v-if="playVideo" ref="videoPlayer" v-on:onClose="onClose"/>
  </div>
</template>

<style lang="scss" scoped>
  .thumb{
    width: 200px;
    height: 100px;
  }
</style>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator';
import VideoPlayer from '@/components/VideoPlayer.vue'; // @ is an alias to /src
import VideoThumbnail from '@/components/VideoThumbnail.vue';
import { $content } from '@/services/content-service';

@Component({
  components: {
    VideoPlayer, VideoThumbnail
  },
})
export default class TestVideoPlayer extends Vue {

  playVideo: boolean = false;

  get videoUrl(): string{
    return $content.getPlaylistForId("A")?.clips[0].clip.fr as string;
  }

  onVideoSelectionRequest(e:any){
    this.playVideo = true;
  }

  onClose(){
    this.playVideo = false;
  }
}
</script>
