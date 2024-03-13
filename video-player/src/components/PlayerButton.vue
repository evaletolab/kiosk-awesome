<template>
  <img 
  ref="element" 
  class="player-button no-select" 
  v-bind:class="{ selected: selected }" 
  :src="source" 
  alt="" 
  draggable="false"
  @click="onClick">
</template>

<style lang="scss" scoped>
  .player-button{
    display: block;
  }
  .hover, .selected{
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
export default class PlayerButton extends Vue {
  @Prop() iconType!: string;
  @Prop({default: false}) selected!: boolean;
  @Prop({default: true}) touchEnabled!: boolean;

  get source(): string{
    return `/icons/${this.iconType}.png`;
  }

  get element(): HTMLElement {
    return this.$refs.element as HTMLElement;
  }

  mounted(){
    if(this.touchEnabled){
      this.element.addEventListener("touchstart", this.onTouchStart);
      this.element.addEventListener("touchend", this.onTouchEnd);
    }
  }

  beforeDestroy(){
    if(this.touchEnabled){
      this.element.removeEventListener("touchstart", this.onTouchStart);
      this.element.removeEventListener("touchend", this.onTouchEnd);
    }
  }

  onTouchStart(ev:TouchEvent){
    // Call preventDefault() to prevent any further handling
    ev.preventDefault();
    
    this.element.classList.add("hover");
    this.onClick(ev);
  }

  onTouchEnd(ev:TouchEvent){
    // console.log("touch end", ev.touches.length);
    this.element.classList.remove("hover");
  }

  onClick(e: Event){
    // chromium special case
    e.stopImmediatePropagation();
    
    if(this.selected) return;

    this.$emit("clickEvt", { type: this.iconType });
  }

}
</script>