import { emitter } from '@kit.BasicServicesKit';
import _ from '@wolfx/lodash';
import { Api_Context, CCApi, ccApiGet, CommonConstants, PreferenceStorage, RouterConstants,
  SystemApi,
  xyApiGet } from '@xy/basic';
import { HomePage } from '@xy/home'
import { MinePage } from '@xy/mine'
import { SystemNoticeModal } from './SystemNoticeModal';

@Component
export struct MainPage {
  @StorageLink('Api_Context') Api_Context: Api_Context = new Api_Context()
  @StorageLink('PreferenceStorage') preferenceStorage: PreferenceStorage = new PreferenceStorage()
  @Link globalPageIndex: string;
  @State backgroundImageY: number = 0;
  @State currentTabIndex: number = 0;
  @StorageProp('bottom') bottom: number = 0;
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_SM;

  aboutToAppear(): void {
    emitter.on("loginOut", async () => {
      await ccApiGet(this.Api_Context.getApiPrefix('ccApi') + CCApi.logout)
      this.preferenceStorage.access_token = undefined
      this.preferenceStorage.refresh_token = undefined
      this.globalPageIndex = RouterConstants.LOGIN_PAGE_URL
    })
    this.getAuthStore()
  }

  async getAuthStore() {
    const response = await xyApiGet(this.Api_Context.getApiPrefix("baseApi_inner") + SystemApi.authStore)
    if (response.success) {
      const profile = (response.data as Record<string, Record<string, Record<string, string>>>).auth.profile
      this.preferenceStorage.node_key = profile.node_key
    }
  }

  @Builder
  BuildTabs(icon: Resource, unIcon: Resource, title: ResourceStr, index: number) {
    Column() {
      Image(this.currentTabIndex === index ? icon : unIcon)
        .width(this.currentTabIndex === index ? $r('app.float.common_select_image_width') :
        $r('app.float.common_image_width'))
        .height(this.currentTabIndex === index ? $r('app.float.common_select_image_height') :
        $r('app.float.common_image_height'))

      if (this.currentTabIndex !== index) {
        Text(title)
          .fontSize($r('app.float.tab_text_size'))
          .lineHeight($r('app.float.tab_text_height'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.tab_un_text'))
      }
    }
  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          Tabs({
            barPosition: this.breakPoint === CommonConstants.BREAK_POINT_LG ? BarPosition.Start : BarPosition.End
          }) {
            TabContent() {
              HomePage({ globalPageIndex: this.globalPageIndex })
            }
            .tabBar(this.BuildTabs($r('app.media.tab_home_active'), $r('app.media.tab_home'),
              $r('app.string.tab_bar_home'), 0))

            TabContent() {
              MinePage({ globalPageIndex: this.globalPageIndex })
            }
            .tabBar(this.BuildTabs($r('app.media.tab_profile_active'), $r('app.media.tab_profile'),
              $r('app.string.tab_bar_mine'), 1))
            .backgroundColor(Color.White)
          }
          .vertical(this.breakPoint === CommonConstants.BREAK_POINT_LG)
          .barWidth(this.breakPoint === CommonConstants.BREAK_POINT_LG ?
          $r('app.float.tab_bar_width') : CommonConstants.TAB_BAR_HEIGHT_PERCENT)
          .barHeight(this.breakPoint === CommonConstants.BREAK_POINT_LG ?
          CommonConstants.TAB_HEIGHT_PERCENT : $r('app.float.tab_bar_height'))
          .backgroundImageSize(ImageSize.Contain)
          .backgroundImagePosition({
            y: this.backgroundImageY
          })
          .backgroundColor($r('app.color.home_background'))
          .scrollable(false)
          .onChange((index: number) => {
            this.currentTabIndex = index;
          })
          .padding({
            bottom: this.bottom
          })
        }
        .width('100%')
      }
      .height('100%')

      SystemNoticeModal()
    }
  }
}
