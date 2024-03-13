<template>
  <img 
    class="player-button" 
    v-bind:class="{ selected: selected }" 
    :src="source" 
    alt="" 
    @click="onClick" />
</template>

<style lang="scss" scoped>
  .player-button{
    display: block;
  }
  .selected{
    filter: invert(100%);
  }
</style>

<script lang="ts">
import { Component, Vue, Prop } from "vue-property-decorator";
import { MEG } from "@/models";
import { $config } from "@/services";

@Component({
  components: { },
})
export default class LangButton extends Vue {
  @Prop() lang!: MEG.Lang;
  @Prop({default: false}) selected!: boolean;

  get source(): string{
    const filename = this.lang == MEG.Lang.FR ? 'video_en.png' : 'video_fr.png';
    return `/icons/${filename}`;
  }

  onClick(e: Event){
    // chromium special case
    e.stopImmediatePropagation();
    const requestedLang = this.lang == MEG.Lang.FR ? MEG.Lang.EN : MEG.Lang.FR;
    this.$emit("requestLang", { requestedLang });
  }

}
</script>