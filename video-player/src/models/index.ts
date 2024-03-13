/* eslint-disable */
// TODO: discuss i18n with client
export namespace MEG {

  export type Id = string;

  export enum Lang { FR = "fr", EN = "en" };

  export interface Translatable{
    fr: string,
    en: string,
  }

  export interface Clip{
    id: Id,
    title: Translatable,
    clip: Translatable,
    duration: string,
    thumbnail: string,
    descriptionMain: Translatable;
    descriptionSecondary: Translatable;
  }

  export class Playlist{
    private _id!: string;
    private _title!: Translatable;
    private _clips: Clip[] = [];

    constructor(id: Id, clipData: any){
      this._id = id;
      this._title = clipData.title;
      this.processClipList(clipData.playlist);
    }

    public get id():Id{
      return this._id;
    }

    public get title(): Translatable{
      return this._title;
    }

    public get clips(): Clip[]{
      return this._clips;
    }

    processClipList(clipData: any[]){
      for(const clipDatum of clipData){
        let clip: Clip = {
          id: clipDatum.id,
          title: clipDatum.title,
          duration: clipDatum.duration || "",
          clip: {
            en: `/videos/${clipDatum.clipName.en}`,
            fr: `/videos/${clipDatum.clipName.fr}`,
          },
          thumbnail: clipDatum.thumbnail,
          descriptionMain: {fr:"", en: ""},
          descriptionSecondary: {fr:"", en: ""},
        }

        if(this._id == "B14"){
          clip.descriptionMain = {
            fr: `${clip.duration}`,
            en: "",
          }
        }else{
          clip.descriptionMain = {
            fr: clipDatum.interviewee.name,
            en: clipDatum.interviewee.name,
          } ;
          clip.descriptionSecondary = {
            fr: `${clipDatum.interviewee.ethnicity.fr}<br>${clipDatum.interviewee.country.fr}<br>${clip.duration}`,
            en: `${clipDatum.interviewee.ethnicity.en}<br>${clipDatum.interviewee.country.en}<br>${clip.duration}`,
          }

          if(this._id == "P"){
            clip.title = {
              fr: clipDatum.interviewee.name,
              en: "",
            }
            clip.descriptionMain = {
              fr: `${clipDatum.interviewee.ethnicity.fr}<br>${clipDatum.interviewee.country.fr}`,
              en: `${clipDatum.interviewee.ethnicity.en}<br>${clipDatum.interviewee.country.en}`,
            }
            clip.descriptionSecondary = {
              fr: `${clip.duration}`,
              en: `${clip.duration}`,
            }
          }
        }
        this._clips.push(clip);
      }
    }
  }
}

