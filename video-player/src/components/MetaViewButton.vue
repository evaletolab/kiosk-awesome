<template>
  <img 
  ref="element" 
  draggable="false" 
  class="no-select"
  :src="source" 
  @click="onClick" 
  alt="">
</template>

<script lang="ts">
import { Component, Vue, Prop } from "vue-property-decorator";
import { $config } from '@/services';

@Component({
  components: { },
})
export default class MetaViewButton extends Vue {
  @Prop() clipId!: string;

  get config() {
    return $config.config;
  }

  get source(): string{
    return `/meta-view/${this.clipId}.png`;
  }

  get element(): HTMLElement {
    return this.$refs.element as HTMLElement;
  }

  onClick(e: Event){
    // chromium special case
    e.stopImmediatePropagation();

    this.$emit("clickEvt", { id: this.clipId });
  }

}
</script>