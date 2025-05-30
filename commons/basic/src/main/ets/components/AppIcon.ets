import { IconConstants } from "../constants/IconConstants";

@Component
export struct AppIcon {
  /**
   * 图标编码
   */
  @Prop iconCode: IconConstants = '';
  /**
   * 外边距
   */
  @Prop iconMargin: Margin | Length | LocalizedMargin = ''
  /**
   * 内边距 扩大图标点击范围
   */
  @Prop iconPadding: Margin | Length | LocalizedMargin = ''
  /**
   * 图标大小
   */
  @Prop iconSize: number | string | Resource = 12
  /**
   * 图标颜色
   */
  @Prop iconColor: ResourceColor = Color.Black;
  /**
   * 背景色
   */
  @Prop iconBackgroundColor: ResourceColor = ''
  /**
   * 边颜色
   */
  @Prop iconBorderColor: ResourceColor | EdgeColors | LocalizedEdgeColors = ''
  /**
   * 边角
   */
  @Prop iconRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0
  /**
   * 边宽
   */
  @Prop iconBorderWidth: Length | EdgeWidths | LocalizedEdgeWidths = 0
  /**
   * 点击按钮
   */
  onClickBtn: (event: ClickEvent) => void = () => {
  }

  build() {
    Text(this.iconCode as string)
      .fontFamily('IconFont')
      .fontSize(this.iconSize)
      .fontColor(this.iconColor)
      .backgroundColor(this.iconBackgroundColor)
      .borderColor(this.iconBorderColor)
      .borderRadius(this.iconRadius)
      .borderWidth(this.iconBorderWidth)
      .margin(this.iconMargin)
      .padding(this.iconPadding)
      .onClick(this.onClickBtn)
  }
}