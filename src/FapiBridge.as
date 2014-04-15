package
{
	import com.brightcove.api.APIModules;
	import com.brightcove.api.CustomModule;
	import com.brightcove.api.brightcove_api;
	import com.brightcove.api.dtos.RenditionAssetDTO;
	import com.brightcove.api.events.ExperienceEvent;
	import com.brightcove.api.events.MediaEvent;
	import com.brightcove.api.modules.AdvertisingModule;
	import com.brightcove.api.modules.ExperienceModule;
	import com.brightcove.api.modules.SocialModule;
	import com.brightcove.api.modules.VideoPlayerModule;
	
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.system.Security;
	
	public class FapiBridge extends CustomModule
	{
		private var _videoModule:VideoPlayerModule;
		private var _experienceModule:ExperienceModule;
		private var _socialModule:SocialModule;
		private var _adModule:AdvertisingModule;
		
		override protected function initialize():void {
			
			_videoModule = player.getModule(APIModules.VIDEO_PLAYER) as VideoPlayerModule;
			_experienceModule = player.getModule(APIModules.EXPERIENCE) as ExperienceModule;
			_socialModule = player.getModule(APIModules.SOCIAL) as SocialModule;
			_adModule = player.getModule(APIModules.ADVERTISING) as AdvertisingModule;
			
			if (ExternalInterface.available) {
				Security.allowDomain('*');
				
				ExternalInterface.addCallback("fapiSetVolume", fapiSetVolume);
				ExternalInterface.addCallback("fapiGetVolume", fapiGetVolume);
				ExternalInterface.addCallback("fapiMute", fapiMute);
				ExternalInterface.addCallback("fapiIsMuted", fapiIsMuted);
				ExternalInterface.addCallback("fapiSetBitRateRange", fapiSetBitRateRange);
				ExternalInterface.addCallback("fapiStopAd", fapiStopAd);
				ExternalInterface.addCallback("fapiSetEmbedCode", fapiSetEmbedCode);
				ExternalInterface.addCallback("fapiSetLink", fapiSetLink);

				var fapiEventListenerAvailable:Boolean = ExternalInterface.call("function() {if (typeof(window.fapiEvent) === 'function') {return true;}}");
				if (fapiEventListenerAvailable) {
					_experienceModule.addEventListener(ExperienceEvent.ENTER_FULLSCREEN,fapiExperienceEventHandler);
					_experienceModule.addEventListener(ExperienceEvent.EXIT_FULLSCREEN,fapiExperienceEventHandler);
					_videoModule.addEventListener(MediaEvent.BUFFER_BEGIN,fapiMediaEventHandler);
					_videoModule.addEventListener(MediaEvent.BUFFER_COMPLETE,fapiMediaEventHandler);
					_videoModule.addEventListener(MediaEvent.MUTE_CHANGE,fapiMediaEventHandler);
					_videoModule.addEventListener(MediaEvent.RENDITION_CHANGE_COMPLETE,fapiMediaEventHandler);
					_videoModule.addEventListener(MediaEvent.RENDITION_CHANGE_REQUEST,fapiMediaEventHandler);
					_videoModule.addEventListener(MediaEvent.VOLUME_CHANGE,fapiMediaEventHandler);
				}
			}		
		}
		
		private function fapiStopAd():void
		{
			_adModule.stopAd();
		}
		private function fapiSetVolume(volume:Number):void
		{
			_videoModule.setVolume(volume);
		}
		private function fapiMute(mute:Boolean = true):void
		{
			_videoModule.mute(mute);
		}
		private function fapiIsMuted():Boolean
		{
			return _videoModule.isMuted();
		}
		private function fapiGetVolume():Number
		{
			return _videoModule.getVolume();
		}
		private function fapiSetLink(linkURL:String):void
		{
			_socialModule.setLink(linkURL);
		}
		private function fapiSetEmbedCode(code:String):void
		{
			_socialModule.setEmbedCode(code);
		}
		private function fapiSetBitRateRange(min:Number, max:Number):void
		{
			_videoModule.setBitRateRange(min,max);
		}
		private function fapiExperienceEventHandler(event:ExperienceEvent):void
		{
			ExternalInterface.call("fapiEvent",event,_experienceModule.getStage().loaderInfo.parameters.flashID);
		}
		private function fapiMediaEventHandler(event:MediaEvent):void
		{
			ExternalInterface.call("fapiEvent",event,_experienceModule.getStage().loaderInfo.parameters.flashID);
		}
	}
}