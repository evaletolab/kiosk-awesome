<template>
  <div>
    <!-- <player-button 
      v-if="isInMetaViewContext" 
      v-on:clickEvt="backToMetaView" 
      touchEnabled=false
      class="back" 
      iconType="back"/> -->
    <playlist-engine 
      :source="playlist" 
      :hasTimer="isInMetaViewContext" 
      :isInMetaViewContext="isInMetaViewContext"
      v-on:backRequestEvt="backToMetaView"
      v-on:timeoutEvt="onTimeout" />
  </div>
</template>

<style scoped>
video {
  width: 80%;
}
.back{
  position: fixed;
  top: 0;
  left: 0;
}
</style>


<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import { $config } from "@/services";
import PlayerButton from "@/components/PlayerButton.vue";
import PlaylistEngine from '../components/PlaylistEngine.vue';

@Component({
  components: {
    PlaylistEngine, PlayerButton,
  },
})
export default class Playlist extends Vue {
  currentPosition = 0;


  get config() {
    return $config.config;
  }

  get media() {
    return this.config.videos[this.currentPosition];
  }

  get playlist() {
    return this.$route.query.playlist || 'A';
  }

  get isInMetaViewContext(): boolean{
    return !!this.$route.query.isMetaViewContext;
  }

  mounted() {
  }

  beforeDestroy() {
  }

  backToMetaView(){
    this.$router.push({path: "MetaView"});
  }

  onTimeout(){
    this.backToMetaView();
  }

}
</script>
