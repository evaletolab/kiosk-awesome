<template>
   <div class="thumb" @click="clickHandler"> 
   </div>
</template>

<style lang="scss" scoped>
    .thumb{
        width: 100%;
        height: 100%;
        background-color: orange;
    }
</style>



<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import { $config } from "@/services";

@Component({
  components: {
  },
})
export default class VideoThumbnail extends Vue {

  get config() {
    return $config.config;
  }

  mounted() {
  }

  beforeDestroy() {
  }

  clickHandler(){
    console.log("on click");
    this.$emit("videoSelectionRequest", {});
  }

}
</script>
