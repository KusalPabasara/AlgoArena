import svgPaths from "./svg-2y6j7mrshz";
import imgLeftArrowBackButtonVectorIconInModernDesignStyleForWebSiteAndMobileApp2Ap88Fm1 from "figma:asset/e5b2d02426dff02ff323daa74a9b12f7fea3649b.png";

function WappGptLogo() {
  return (
    <div className="absolute bottom-0 left-[1.42%] right-[-1.42%] top-0" data-name="WappGPT - logo">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 48 48">
        <g id="WappGPT - logo">
          <path clipRule="evenodd" d={svgPaths.pf735300} fill="var(--fill-0, white)" fillRule="evenodd" id="Vector" />
          <g id="Vector_2"></g>
          <path d={svgPaths.p1c21a500} fill="var(--fill-0, white)" id="Vector_3" />
          <rect fill="var(--fill-0, #162550)" height="8.08988" id="Rectangle 17" rx="4.04494" width="22.8741" x="12.2546" y="10.0675" />
          <ellipse cx="29.9997" cy="14.0675" fill="var(--fill-0, #04FED1)" id="Ellipse 18" rx="1.49771" ry="1.48315" />
          <ellipse cx="23.6455" cy="34.0224" fill="var(--fill-0, #162550)" id="Ellipse 19" rx="1.49771" ry="1.48315" />
          <ellipse cx="17.6553" cy="14.0675" fill="var(--fill-0, #04FED1)" id="Ellipse 20" rx="1.49771" ry="1.48315" />
          <ellipse cx="17.6553" cy="34.0224" fill="var(--fill-0, #162550)" id="Ellipse 21" rx="1.49771" ry="1.48315" />
          <ellipse cx="29.637" cy="34.0224" fill="var(--fill-0, #162550)" id="Ellipse 22" rx="1.49771" ry="1.48315" />
        </g>
      </svg>
    </div>
  );
}

function Logo() {
  return (
    <div className="absolute h-[48px] left-[calc(50%-0.33px)] top-1/2 translate-x-[-50%] translate-y-[-50%] w-[47.333px]" data-name="Logo">
      <WappGptLogo />
    </div>
  );
}

function Logo1() {
  return (
    <div className="relative rounded-[53.333px] shrink-0 size-[48px]" data-name="logo">
      <Logo />
    </div>
  );
}

function BrandName() {
  return (
    <div className="h-[29px] relative shrink-0 w-[118px]" data-name="brand name">
      <p className="absolute bottom-0 font-['Inter:Bold',sans-serif] font-bold leading-[normal] left-0 not-italic right-[1.69%] text-[24px] text-black text-nowrap top-0 whitespace-pre">LeoAssist</p>
    </div>
  );
}

function LeftSide() {
  return (
    <div className="content-stretch flex flex-col items-start justify-center relative shrink-0" data-name="Left Side">
      <BrandName />
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex gap-[9px] items-center relative shrink-0">
      <Logo1 />
      <LeftSide />
    </div>
  );
}

function EditHeaderContent() {
  return (
    <div className="absolute content-stretch flex h-[42px] items-center justify-between left-0 min-h-[42px] top-[23px] w-[203px]" data-name="✏️ EDIT HEADER CONTENT">
      <Frame />
    </div>
  );
}

function Header() {
  return (
    <div className="absolute content-stretch flex flex-col gap-[10px] h-[88px] items-start left-[133.97px] overflow-clip top-[287.67px] w-[400px]" data-name="🧠 header">
      <EditHeaderContent />
    </div>
  );
}

function Bubbles() {
  return (
    <div className="absolute h-[513.444px] left-[-131.97px] overflow-clip top-[-205.67px] w-[659.329px]" data-name="Bubbles">
      <div className="absolute bottom-[56.38px] flex items-center justify-center left-0 right-[233.37px] top-0">
        <div className="flex-none h-[367.298px] rotate-[158deg] w-[311.014px]">
          <div className="relative size-full" data-name="bubble 02">
            <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 312 368">
              <path d={svgPaths.pe2b6900} fill="var(--fill-0, #FFD700)" id="bubble 02" />
            </svg>
          </div>
        </div>
      </div>
      <div className="absolute h-[266.77px] left-[415.7px] top-[246.67px] w-[243.628px]" data-name="bubble 01">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 244 267">
          <path d={svgPaths.p2b951e00} fill="var(--fill-0, #02091A)" id="bubble 01" />
        </svg>
      </div>
      <Header />
    </div>
  );
}

function Bar() {
  return (
    <div className="absolute contents left-[calc(33.33%-2px)] top-[861px]" data-name="Bar">
      <div className="absolute bg-black h-[5.442px] left-[calc(33.33%-2px)] rounded-[34px] top-[861px] w-[145.848px]" data-name="Bar" />
    </div>
  );
}

function Tags() {
  return (
    <div className="basis-0 bg-[#f3f5f6] grow min-h-px min-w-px relative rounded-[10px] shadow-[0px_1px_0px_0px_rgba(0,0,0,0.12)] shrink-0" data-name="🗒️tags">
      <div className="flex flex-row items-center size-full">
        <div className="box-border content-stretch flex gap-[10px] items-center px-[16px] py-[6px] relative w-full">
          <p className="font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[normal] not-italic opacity-90 relative shrink-0 text-[#444444] text-[12px] text-nowrap whitespace-pre">What is LeoAssist?</p>
        </div>
      </div>
    </div>
  );
}

function Tags1() {
  return (
    <div className="bg-[#f3f5f6] box-border content-stretch flex gap-[10px] items-center px-[16px] py-[6px] relative rounded-[10px] shadow-[0px_1px_0px_0px_rgba(0,0,0,0.12)] shrink-0" data-name="🗒️tags">
      <p className="font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[normal] not-italic opacity-90 relative shrink-0 text-[#444444] text-[12px] text-nowrap whitespace-pre">What is Leo club?</p>
    </div>
  );
}

function Tags2() {
  return (
    <div className="bg-[#f3f5f6] box-border content-stretch flex gap-[10px] items-center px-[16px] py-[6px] relative rounded-[10px] shadow-[0px_1px_0px_0px_rgba(0,0,0,0.12)] shrink-0" data-name="🗒️tags">
      <p className="font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[normal] not-italic opacity-90 relative shrink-0 text-[#444444] text-[12px] text-nowrap whitespace-pre">FAQs</p>
    </div>
  );
}

function TagContainer() {
  return (
    <div className="content-stretch flex gap-[8px] items-start relative shrink-0 w-full" data-name="tag container">
      <Tags />
      <Tags1 />
      <Tags2 />
    </div>
  );
}

function VuesaxLinearSend() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/linear/send">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 24 24">
        <g id="send">
          <path d={svgPaths.p33c43d00} id="Vector" stroke="var(--stroke-0, #8F7902)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" />
          <path d="M5.44 12H10.84" id="Vector_2" stroke="var(--stroke-0, #8F7902)" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" />
          <path d="M23.5 0.5V23.5H0.5V0.5H23.5Z" id="Vector_3" opacity="0" stroke="var(--stroke-0, #8F7902)" />
        </g>
      </svg>
    </div>
  );
}

function VuesaxLinearSend1() {
  return (
    <div className="relative shrink-0 size-[24px]" data-name="vuesax/linear/send">
      <VuesaxLinearSend />
    </div>
  );
}

function TextArea() {
  return (
    <div className="bg-[#e8ebf0] relative rounded-[16px] shrink-0 w-full" data-name="text area">
      <div className="overflow-clip rounded-[inherit] size-full">
        <div className="box-border content-stretch flex gap-[75px] items-start px-[22px] py-[20px] relative w-full">
          <p className="font-['Inter:Regular',sans-serif] font-normal leading-[normal] not-italic relative shrink-0 text-[#444444] text-[18px] text-nowrap whitespace-pre">Type your message here...</p>
          <VuesaxLinearSend1 />
        </div>
      </div>
      <div aria-hidden="true" className="absolute border-[#f3f5f6] border-[1px_0px_0px] border-solid inset-0 pointer-events-none rounded-[16px]" />
    </div>
  );
}

function Footer() {
  return (
    <div className="absolute bg-white box-border content-stretch flex flex-col gap-[6px] items-start left-[2px] p-[16px] rounded-bl-[20px] rounded-br-[20px] shadow-[0px_-4px_16px_0px_rgba(0,0,0,0.08)] top-[731px] w-[400px]" data-name="👞 Footer 4">
      <TagContainer />
      <TextArea />
    </div>
  );
}

function Messages() {
  return (
    <div className="basis-0 content-stretch flex gap-[10px] grow items-end justify-end min-h-px min-w-px relative shrink-0" data-name="✏️ Messages">
      <p className="basis-0 font-['Inter:Regular',sans-serif] font-normal grow leading-[normal] min-h-px min-w-px not-italic relative shrink-0 text-[15px] text-white">Hello Kusal ! How can I help you today?</p>
    </div>
  );
}

function Timestamp() {
  return (
    <div className="h-[7px] relative shrink-0 w-[20px]" data-name="timestamp">
      <p className="absolute bottom-0 font-['Inter:Regular',sans-serif] font-normal leading-[normal] left-0 not-italic right-[-5%] text-[#888888] text-[10px] text-nowrap top-0 whitespace-pre">7:20</p>
    </div>
  );
}

function Frame1() {
  return (
    <div className="absolute bottom-[-18px] content-stretch flex gap-[10px] items-end left-[32px]">
      <Timestamp />
    </div>
  );
}

function BubbleSender() {
  return (
    <div className="bg-[#8f7902] opacity-[0.77] relative rounded-br-[12px] rounded-tl-[12px] rounded-tr-[12px] shadow-[0px_2px_1px_0px_rgba(0,0,0,0.05)] shrink-0 w-full" data-name="👨‍💻 Bubble Sender">
      <div className="flex flex-row items-end size-full">
        <div className="box-border content-stretch flex gap-[10px] items-end pb-[32px] pl-[20px] pr-[16px] pt-[16px] relative w-full">
          <Messages />
          <div className="absolute bottom-[-21px] h-[34px] left-0 w-[45px]">
            <div className="absolute bottom-[8.89%] left-0 right-[13.2%] top-0">
              <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 40 31">
                <path d={svgPaths.pbcffa00} fill="var(--fill-0, #8F7902)" id="Rectangle 1" />
              </svg>
            </div>
          </div>
          <Frame1 />
        </div>
      </div>
    </div>
  );
}

function VuesaxOutlineClipboardText() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/outline/clipboard-text">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 16 16">
        <g id="clipboard-text">
          <path d={svgPaths.p3493d270} fill="var(--fill-0, black)" id="Vector" />
          <path d={svgPaths.p33072a00} fill="var(--fill-0, black)" id="Vector_2" />
          <path d={svgPaths.p6a54a80} fill="var(--fill-0, black)" id="Vector_3" />
          <path d={svgPaths.p2c865900} fill="var(--fill-0, black)" id="Vector_4" />
          <path d="M16 0H0V16H16V0Z" fill="var(--fill-0, black)" id="Vector_5" opacity="0" />
        </g>
      </svg>
    </div>
  );
}

function VuesaxOutlineClipboardText1() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="vuesax/outline/clipboard-text">
      <VuesaxOutlineClipboardText />
    </div>
  );
}

function VuesaxLinearLike() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/linear/like">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 16 16">
        <g id="like">
          <path d={svgPaths.p2a552c80} id="Vector" stroke="var(--stroke-0, black)" strokeMiterlimit="10" />
          <path d={svgPaths.p2cac8d00} id="Vector_2" stroke="var(--stroke-0, black)" strokeLinecap="round" strokeLinejoin="round" />
          <path d="M15.5 0.5V15.5H0.5V0.5H15.5Z" id="Vector_3" opacity="0" stroke="var(--stroke-0, black)" />
        </g>
      </svg>
    </div>
  );
}

function VuesaxLinearLike1() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="vuesax/linear/like">
      <VuesaxLinearLike />
    </div>
  );
}

function VuesaxLinearDislike() {
  return (
    <div className="absolute contents inset-0" data-name="vuesax/linear/dislike">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 16 16">
        <g id="dislike">
          <path d={svgPaths.p194d0500} id="Vector" stroke="var(--stroke-0, black)" strokeMiterlimit="10" />
          <path d={svgPaths.p1bab7400} id="Vector_2" stroke="var(--stroke-0, black)" strokeLinecap="round" strokeLinejoin="round" />
          <path d="M15.5 0.5V15.5H0.5V0.5H15.5Z" id="Vector_3" opacity="0" stroke="var(--stroke-0, black)" />
        </g>
      </svg>
    </div>
  );
}

function VuesaxLinearDislike1() {
  return (
    <div className="relative shrink-0 size-[16px]" data-name="vuesax/linear/dislike">
      <VuesaxLinearDislike />
    </div>
  );
}

function Component3Icons() {
  return (
    <div className="bg-[gold] box-border content-stretch flex gap-[8px] items-start p-[4px] relative rounded-[8px] shrink-0" data-name="3 icons">
      <VuesaxOutlineClipboardText1 />
      <VuesaxLinearLike1 />
      <VuesaxLinearDislike1 />
    </div>
  );
}

function CopyLikeDislike() {
  return (
    <div className="absolute bottom-[8px] box-border content-stretch flex gap-[7px] items-start px-[20px] py-0 right-[16px]" data-name="⏲ copy like dislike">
      <Component3Icons />
    </div>
  );
}

function BrandColor() {
  return <div className="absolute bg-[gold] inset-0 rounded-[100px]" data-name="brand color" />;
}

function WappGptLogo1() {
  return (
    <div className="absolute bottom-0 left-[1.42%] right-[-1.42%] top-0" data-name="WappGPT - logo">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 33 33">
        <g id="WappGPT - logo">
          <path clipRule="evenodd" d={svgPaths.pe046c00} fill="var(--fill-0, white)" fillRule="evenodd" id="Vector" />
          <g id="Vector_2"></g>
          <path d={svgPaths.p755600} fill="var(--fill-0, white)" id="Vector_3" />
          <rect fill="var(--fill-0, #162550)" height="5.5618" id="Rectangle 17" rx="2.7809" width="15.573" x="8.34305" y="6.92138" />
          <ellipse cx="20.4241" cy="9.67142" fill="var(--fill-0, #04FED1)" id="Ellipse 18" rx="1.01966" ry="1.01966" />
          <ellipse cx="16.098" cy="23.3904" fill="var(--fill-0, #162550)" id="Ellipse 19" rx="1.01966" ry="1.01966" />
          <ellipse cx="12.0201" cy="9.67142" fill="var(--fill-0, #04FED1)" id="Ellipse 20" rx="1.01966" ry="1.01966" />
          <ellipse cx="12.0201" cy="23.3904" fill="var(--fill-0, #162550)" id="Ellipse 21" rx="1.01966" ry="1.01966" />
          <ellipse cx="20.1772" cy="23.3904" fill="var(--fill-0, #162550)" id="Ellipse 22" rx="1.01966" ry="1.01966" />
        </g>
      </svg>
    </div>
  );
}

function Logo2() {
  return (
    <div className="absolute h-[33px] left-[calc(50%+0.11px)] top-[calc(50%-0.5px)] translate-x-[-50%] translate-y-[-50%] w-[32.225px]" data-name="Logo">
      <WappGptLogo1 />
    </div>
  );
}

function Logo3() {
  return (
    <div className="absolute bottom-[-29.5px] left-0 rounded-[80px] size-[48px]" data-name="logo">
      <BrandColor />
      <Logo2 />
    </div>
  );
}

function SystemMessage() {
  return (
    <div className="absolute box-border content-stretch flex flex-col gap-[7px] items-start justify-end left-[11px] pb-[20px] pt-0 px-[20px] top-[586px] w-[359px]" data-name="👈🏻👈🏻 System Message">
      <BubbleSender />
      <CopyLikeDislike />
      <Logo3 />
    </div>
  );
}

function Border() {
  return (
    <div className="absolute bottom-0 left-0 right-[2.33px] top-0" data-name="Border">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 22 12">
        <g clipPath="url(#clip0_1_774)" id="Border">
          <g id="Shape"></g>
          <mask height="12" id="mask0_1_774" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="22" x="0" y="0">
            <path d={svgPaths.p260541f0} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_774)">
            <path d={svgPaths.p2ca600} id="Fill" stroke="var(--stroke-0, black)" strokeOpacity="0.34902" strokeWidth="2" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_774">
            <rect fill="white" height="11.3333" width="22" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Cap() {
  return (
    <div className="absolute h-[4px] right-0 top-1/2 translate-y-[-50%] w-[1.328px]" data-name="Cap">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 2 4">
        <g id="Cap">
          <g id="Shape"></g>
          <mask height="4" id="mask0_1_769" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="2" x="0" y="0">
            <path d={svgPaths.p2b99ae00} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_769)">
            <path d="M-5 -5H6.328V9H-5V-5Z" fill="var(--fill-0, black)" fillOpacity="0.4" id="Fill" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function Capacity() {
  return (
    <div className="absolute h-[7.333px] left-[2px] top-1/2 translate-y-[-50%] w-[18px]" data-name="Capacity">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 18 8">
        <g id="Capacity">
          <g id="Shape"></g>
          <mask height="8" id="mask0_1_764" maskUnits="userSpaceOnUse" style={{ maskType: "alpha" }} width="18" x="0" y="0">
            <path d={svgPaths.p8246f00} fill="var(--fill-0, black)" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_764)">
            <path d="M-5 -5H23V12.3333H-5V-5Z" fill="var(--fill-0, black)" id="Fill" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function Battery() {
  return (
    <div className="absolute h-[11.333px] overflow-clip right-[27.67px] top-[calc(50%+1px)] translate-y-[-50%] w-[24.328px]" data-name="Battery">
      <Border />
      <Cap />
      <Capacity />
    </div>
  );
}

function Wifi() {
  return (
    <div className="absolute h-[10.966px] overflow-clip right-[54.03px] top-[calc(50%+0.81px)] translate-y-[-50%] w-[15.272px]" data-name="Wifi">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 16 11">
        <g clipPath="url(#clip0_1_827)" id="Wifi">
          <g id="Shape"></g>
          <mask height="11" id="mask0_1_827" maskUnits="userSpaceOnUse" style={{ maskType: "luminance" }} width="16" x="0" y="0">
            <path clipRule="evenodd" d={svgPaths.p35f5d700} fill="var(--fill-0, white)" fillRule="evenodd" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_827)">
            <path d={svgPaths.p592eaf0} fill="var(--fill-0, black)" id="Fill" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_827">
            <rect fill="white" height="10.9656" width="15.2724" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function CellularConnection() {
  return (
    <div className="absolute h-[10.667px] left-[calc(50%+104.17px)] overflow-clip top-[calc(50%+1px)] translate-x-[-50%] translate-y-[-50%] w-[17px]" data-name="Cellular Connection">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 17 11">
        <g clipPath="url(#clip0_1_751)" id="Cellular Connection">
          <g id="Shape"></g>
          <mask height="11" id="mask0_1_751" maskUnits="userSpaceOnUse" style={{ maskType: "luminance" }} width="17" x="0" y="0">
            <path clipRule="evenodd" d={svgPaths.p35ce9400} fill="var(--fill-0, white)" fillRule="evenodd" id="Shape_2" />
          </mask>
          <g mask="url(#mask0_1_751)">
            <path d="M-8 -5H19V15.6667H-8V-5Z" fill="var(--fill-0, black)" id="Fill" />
          </g>
        </g>
        <defs>
          <clipPath id="clip0_1_751">
            <rect fill="white" height="10.6667" width="17" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function BarsTimeBlack() {
  return (
    <div className="absolute inset-[29.55%_80%_29.55%_5.6%] overflow-clip" data-name="Bars/_/Time Black">
      <div className="absolute bottom-[1.64px] left-0 right-[-0.11px] top-0" data-name="Background">
        <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
          <g id="Background"></g>
        </svg>
      </div>
      <p className="absolute font-['Nunito_Sans:SemiBold',sans-serif] font-semibold h-[16px] leading-[normal] left-0 right-0 text-[14px] text-black text-center top-[calc(50%-6.82px)] tracking-[0.0039px]" style={{ fontVariationSettings: "'YTLC' 500, 'wdth' 100" }}>
        9:41
      </p>
    </div>
  );
}

function BarsStatusBarLightStatusBar() {
  return (
    <div className="absolute h-[48px] left-0 overflow-clip top-0 w-[402px]" data-name="Bars/Status Bar/Light Status Bar">
      <svg className="block size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 32 32">
        <g id="Background"></g>
      </svg>
      <Battery />
      <Wifi />
      <CellularConnection />
      <BarsTimeBlack />
    </div>
  );
}

export default function LeoAssist() {
  return (
    <div className="bg-white relative size-full" data-name="LeoAssist">
      <Bubbles />
      <Bar />
      <div className="absolute h-[53px] left-[10px] top-[50px] w-[49.568px]" data-name="left-arrow-back-button-vector-icon-in-modern-design-style-for-web-site-and-mobile-app-2AP88FM 1">
        <img alt="" className="absolute inset-0 max-w-none object-50%-50% object-cover pointer-events-none size-full" src={imgLeftArrowBackButtonVectorIconInModernDesignStyleForWebSiteAndMobileApp2Ap88Fm1} />
      </div>
      <Footer />
      <SystemMessage />
      <BarsStatusBarLightStatusBar />
    </div>
  );
}